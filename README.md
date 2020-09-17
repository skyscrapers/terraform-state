# terraform-state

Everything for state related terraform

## s3

Create an S3 bucket to store the Terraform state files and a DynamoDB table to support state locking.
The bucket has server-side encryption enabled by default and the bucket policy enforces it for all uploads.

### Available variables

| Name    | Description  |  Type  | Default | Required |
| ------- | ------------ | :----: | :-----: | :------: |
| project | Project name | string |   n/a   |   yes    |

### Output

| Name             | Description                                                                   |
| ---------------- | ----------------------------------------------------------------------------- |
| bucket\_id       | Id (name) of the S3 bucket                                                    |
| locktable\_id    | Id (name) of the DynamoDB lock table                                          |
| tf\_policy\_arn  | The ARN of the policy for Terraform users to access the state and lock table  |
| tf\_policy\_id   | The ID of the policy for Terraform users to access the state and lock table   |
| tf\_policy\_name | The name of the policy for Terraform users to access the state and lock table |

### Example

```tf
module "s3" {
  source  = "github.com/skyscrapers/terraform-state//s3?ref=4.0.0"
  project = "some-project"
}
```

After applying the module, you can configure your Terraform backend like this:

```tf
terraform {
  backend "s3" {
    key            = "something" # this should be different for each Terraform configuration / stack you have
    bucket         = "terraform-remote-state-some-project"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-remote-state-lock-some-project"
    acl            = "bucket-owner-full-control"
  }
}
```

### Multi-account AWS Architecture

When running Terraform on a multi-account AWS setup (e.g. an account per environment), it's recommended to setup a single S3 bucket (and DynamoDB lock table) in an "administrative" AWS account for the Terraform state. Please read the [Terraform S3 backend documentation](https://www.terraform.io/docs/backends/types/s3.html#multi-account-aws-architecture) for more information on this topic.

## azurerm

Creates an Azure resource group, a Storage account and a storage container to use as a Terraform backend.

### Variables

| Name     | Description                                      | Type  | Default | Required |
| -------- | ------------------------------------------------ | ----- | ------- | :------: |
| location | Azure region where to deploy the storage account | `any` | n/a     |   yes    |
| project  | Project name                                     | `any` | n/a     |   yes    |

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
  source   = "github.com/skyscrapers/terraform-state//azurerm?ref=5.0.0"
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
