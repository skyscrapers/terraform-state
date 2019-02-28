# terraform-state

Everything for state related terraform

## s3

Create an S3 bucket to store the Terraform state files and a DynamoDB table to support state locking.
The bucket has server-side encryption enabled by default and the bucket policy enforces it for all uploads.

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| project | Project name | string | n/a | yes |

### Output

| Name | Description |
|------|-------------|
| bucket\_id | Id (name) of the S3 bucket |
| locktable\_id | Id (name) of the DynamoDB lock table |
| tf\_policy\_arn | The ARN of the policy for Terraform users to access the state and lock table |
| tf\_policy\_id | The ID of the policy for Terraform users to access the state and lock table |
| tf\_policy\_name | The name of the policy for Terraform users to access the state and lock table |

### Example

```tf
module "s3" {
  source  = "github.com/skyscrapers/terraform-state//s3?ref=3.0.0"
  project = "some-project"
}
```

### Multi-account AWS Architecture

When running Terraform on a multi-account AWS setup (e.g. an account per environment), it's recommended to setup a single S3 bucket (and DynamoDB lock table) in an "administrative" AWS account for the Terraform state. Please read the [Terraform S3 backend documentation](https://www.terraform.io/docs/backends/types/s3.html#multi-account-aws-architecture) for more information on this topic.
