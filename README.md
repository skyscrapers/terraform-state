# terraform-state
Everything for state related terraform

## s3
Create an S3 bucket to store the Terraform state file and a DynamoDB table (can be disabled) to support state locking.
The bucket has an policy where you can only upload files with encryption enabled.

### Available variables:
 * [`environment`]: String(optional): the name of the environment this state belongs to (prod,stag,dev). If omitted, all the resource names won't contain any environment information.
 * [`project`]: String(required): the name of the project this state belongs to.
 * [`create_dynamodb_lock_table`]: String(optional): toggle to enable or not the DynamoDB table creation. Set to false to disable. Defaults to true.
 * [`create_s3_bucket`]: String(optional): toggle to enable or not the S3 bucket creation. Set to false to disable. Defaults to true.
 * [`shared_aws_account_ids`]: List(optional): A list of AWS account IDs to share the S3 bucket and DynamoDB table with. Defaults to [].

### Output:
 * [`bucket_id`]: String: The name of the bucket
 * [`locktable_id`]: String: the id of the DynamoDB lock table.

### Example single environment

```
module "s3" {
  source      = "github.com/skyscrapers/terraform-state//s3?ref=1.0.0"
  environment = "test"
  project     = "some-project"
}
```

### Example using terraform environments

When using terraform environments, there's only one remote backend configuration, meaning that there can only be one single bucket for all the environments. That also means that this module can only be managed from one single environment, otherwise you'll get conflicts in terraform. In order to do this you'll have to disable this module on all but one environment. For example like this:

```
module "s3" {
  source                     = "github.com/skyscrapers/terraform-state//s3?ref=1.0.0"
  project                    = "some-project"
  create_dynamodb_lock_table = "${terraform.env == "production" ? "true" : "false"}"
  create_s3_bucket           = "${terraform.env == "production" ? "true" : "false"}"
}
```

Note that you'll also need to drop the `environment` variable, as the bucket will be used for more than one environment.

### Example using terraform environment on multiple AWS accounts

This use-case is a bit more tricky than the previous one: you're using terraform environments and each environment is deployed on a different AWS account.

In this case the same bucket still needs to be used for all the environments, so the bucket is going to be created in one of the AWS accounts, and shared with the rest of them. This way all the environments can access the same bucket.

The DynamoDB lock table is a different story, as it can't be shared with other AWS account in the same way as the S3 bucket. In this case a separate DynamoDB table is going to be created for each AWS account (and terraform environment). But as DynamoDB table names don't need to be unique across AWS account, that's not going to be an issue.

TL;DR There's going to be a single S3 bucket for all the terraform environments (and AWS accounts), but managed from a single environment. And there's going to be a different DynamoDB lock table for each environment (and AWS account).

```
module "s3" {
  source                     = "github.com/skyscrapers/terraform-state//s3?ref=1.0.0"
  project                    = "some-project"
  create_s3_bucket           = "${terraform.env == "production" ? "true" : "false"}"
  shared_aws_account_ids     = [
    "857538549606", # test
    "941014208174", # production
    "987571789175", # staging
  ]
}
```
