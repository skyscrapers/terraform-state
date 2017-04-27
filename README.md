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

### Example
```
module "s3" {
  source      = "github.com/skyscrapers/terraform-state//s3?ref=1.0.0"
  environment = "test"
  project     = "some-project"
}
```

## TODO

Document multi-environment setup use-case.
