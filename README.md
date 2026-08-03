# terraform-state

Everything for state related terraform

## s3

Create an S3 bucket to store the Terraform state files, with native S3 state locking (no DynamoDB table required).
The bucket has server-side encryption enabled by default and the bucket policy enforces it for all uploads.
Optionally, the state bucket is replicated to a second bucket in another region and/or another AWS account, for disaster recovery.

### Available variables

| Name        | Description                                                            |  Type  | Default | Required |
| ----------- | ---------------------------------------------------------------------- | :----: | :-----: | :------: |
| project     | Project name                                                           | string |   n/a   |   yes    |
| replication | Replication of the state bucket, see [Replication](#replication) below | object |   `{}`  |    no    |

### Output

| Name                   | Description                                                                                     |
| ---------------------- | ----------------------------------------------------------------------------------------------- |
| bucket\_id             | Id (name) of the S3 bucket                                                                      |
| replica\_bucket\_arn   | ARN of the replica S3 bucket, null when replication is disabled                                 |
| replica\_bucket\_id    | Id (name) of the replica S3 bucket, null when replication is disabled                           |
| replication\_role\_arn | ARN of the IAM role S3 assumes to replicate the state bucket, null when replication is disabled |
| tf\_policy\_arn        | The ARN of the policy for Terraform users to access the state and S3-native lock files          |
| tf\_policy\_id         | The ID of the policy for Terraform users to access the state and S3-native lock files           |
| tf\_policy\_name       | The name of the policy for Terraform users to access the state and S3-native lock files         |

### Example

```tf
module "s3" {
  source  = "github.com/skyscrapers/terraform-state//s3?ref=7.0.0"
  project = "some-project"

  # Required even without replication: alias it to the primary provider.
  providers = {
    aws         = aws
    aws.replica = aws
  }
}
```

After applying the module, you can configure your Terraform backend like this:

```tf
terraform {
  backend "s3" {
    key          = "something" # this should be different for each Terraform configuration / stack you have
    bucket       = "terraform-remote-state-some-project"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
    acl          = "bucket-owner-full-control"
  }
}
```

### Replication

The module can replicate the state bucket to a replica bucket, so the Terraform state survives the loss of a region or of the account holding the state. Replication is off by default.

The replica bucket is created with the `aws.replica` provider, so that provider decides where the replica lands: point it at another region for cross-region replication, at another account for cross-account replication, or at both at once. The `aws.replica` provider must always be passed, also when replication is disabled; alias it to the primary provider in that case.

When `replication.enabled` is `true`, the module creates:

- the replica bucket, with versioning, `AES256` encryption, a public access block, and ACLs disabled (`BucketOwnerEnforced`), so the replica account owns the replicated objects
- a bucket policy on the replica granting the replication role write access
- an IAM role in the source account that S3 assumes to replicate, scoped to the state bucket and the replica bucket
- the replication configuration on the state bucket, replicating all objects

Replication settings (`replication`):

| Name                       | Description                                                                                |  Type  |   Default    |
| -------------------------- | ------------------------------------------------------------------------------------------ | :----: | :----------: |
| enabled                    | Whether to replicate the state bucket                                                      |  bool  |   `false`    |
| storage\_class             | Storage class of the replicated objects                                                    | string | `"STANDARD"` |
| replicate\_delete\_markers | Whether to replicate delete markers, so deletes in the state bucket show up in the replica |  bool  |   `false`    |

Example, replicating to the `backup` account in `eu-central-1`:

```tf
provider "aws" {
  alias   = "backup_dr"
  region  = "eu-central-1"
  profile = "backup"
}

module "s3" {
  source  = "github.com/skyscrapers/terraform-state//s3?ref=7.0.0"
  project = "some-project"

  replication = {
    enabled = true
  }

  providers = {
    aws         = aws
    aws.replica = aws.backup_dr
  }
}
```

Things to know:

- **Objects that already exist are not replicated.** S3 only replicates objects written after the replication configuration is in place, so an existing state bucket has to be seeded once with an [S3 Batch Replication](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-batch-replication-batch.html) job (or a one-off `aws s3 sync`). Without it, the replica only fills up as each stack writes its state again.
- Object deletions are never replicated: S3 does not replicate the deletion of a specific object version, and delete markers are only replicated when `replicate_delete_markers` is on. So the replica keeps its copies even if the state bucket is emptied.
- To recover, point the backend at the replica bucket (`bucket` and `region`) and run `terragrunt init -reconfigure` or `tofu init -reconfigure`.
- The replica bucket policy names the replication role. IAM is eventually consistent, so a first apply can fail with an "Invalid principal in policy" error; re-running it fixes that.

### Multi-account AWS Architecture

When running Terraform on a multi-account AWS setup (e.g. an account per environment), it's recommended to setup a single S3 bucket in an "administrative" AWS account for the Terraform state. Please read the [Terraform S3 backend documentation](https://www.terraform.io/docs/backends/types/s3.html#multi-account-aws-architecture) for more information on this topic.

## azurerm

Creates an Azure resource group, a Storage account and a storage container to use as a Terraform backend.

### Variables

| Name     | Description                                      | Type  | Default | Required |
| -------- | ------------------------------------------------ | ----- | ------- | :------: |
| location | Azure region where to deploy the storage account | `any` | n/a     |   yes    |
| project  | Project name                                     | `any` | n/a     |   yes    |
| tags     | Additional tags to add to the created resources  | `map` | `{}`    |    no    |

### Outputs

| Name                   | Description                                                      |
| ---------------------- | ---------------------------------------------------------------- |
| resource_group_id      | Resource group ID where the storage account is deployed          |
| resource_group_name    | Resource group name where the storage account is deployed        |
| storage_account_id     | Storage account ID where the Terraform backend should point to   |
| storage_account_name   | Storage account name where the Terraform backend should point to |
| storage_container_id   | Storage container ID where to put the Terraform state files      |
| storage_container_name | Storage container name where to put the Terraform state files    |

### Examples

```tf
module "tf_backend_azurerm" {
  source   = "github.com/skyscrapers/terraform-state//azurerm?ref=7.0.0"
  project  = "someproject"
  location = "North Europe"
}
```

After applying the module, you can configure your Terraform backend like this:

```tf
terraform {
  backend "azurerm" {
    key                  = "stacks/aks-cluster.tfstate"
    resource_group_name  = "terraform-remote-state-someproject"
    storage_account_name = "tfbackendsomeproject"
    container_name       = "tf-state"
  }
}
```
