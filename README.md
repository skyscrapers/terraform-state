# terraform-state
Everything for state related terraform

## s3
Create a bucket to store the Terraform state file. This bucket has an policy where you can only upload files with encryption enabled.

### Available variables:
 * [`environment`]: String(required): the name of the environment these subnets belong to (prod,stag,dev)
 * [`project`]: String(required): the name of the project these subnets belong to

### Output:
 * [`id`]: String: The name of the bucket

### Example
```
module "s3" {
  source = "s3"
  environment = "test"
  project = "some-project"
}
```
