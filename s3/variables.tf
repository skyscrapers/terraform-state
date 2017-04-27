variable "project" {
  description = "Project name"
}

variable "environment" {
  description = "Environment name"
}

variable "create_dynamodb_lock_table" {
  description = "Also create a DynamoDB table for state locking. Set to false or 0 to disable. Defaults to true"
  default     = "true"
}

variable "shared_aws_account_ids" {
  description = "A list of AWS account IDs to share the S3 bucket and DynamoDB table with."
  type        = "list"
  default     = []
}
