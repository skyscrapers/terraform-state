# terraform-state
Everything for state related terraform

## s3
Create a bucket to store the Terraform state file. This bucket has an policy where you can only upload files with encryption enabled.

### Available variables:
 * [`environment`]: String(required): the name of the environment this state belongs to (prod,stag,dev)
 * [`project`]: String(required): the name of the project this state belongs to

### Output:
 * [`id`]: String: The name of the bucket

### Example
```
module "s3" {
  source = "github.com/skyscrapers/terraform-state//s3?ref=<git_hash>"
  environment = "test"
  project = "some-project"
}
```

## s3-with-locking
Create a bucket to store the Terraform state file and a DynamoDB table to support state locking.
This bucket has an policy where you can only upload files with encryption enabled.

### Available variables:
 * [`environment`]: String(required): the name of the environment this state belongs to (prod,stag,dev)
 * [`project`]: String(required): the name of the project these state belongs to

### Output:
 * [`bucket-id`]: String: The name of the bucket
 * [`locktable-id`]: String: the id of the DynamoDB lock table.

### Example
```
module "s3-with-locking" {
  source = "github.com/skyscrapers/terraform-state//s3-with-locking?ref=<git_hash>"
  environment = "test"
  project = "some-project"
}
```
