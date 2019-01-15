output "bucket_id" {
  description = "Id (name) of the S3 bucket"
  value       = "${join("", aws_s3_bucket.state.*.id)}"
}

output "locktable_id" {
  description = "Id (name) of the DynamoDB lock table"
  value       = "${join("", aws_dynamodb_table.terraform_state_locktable.*.id)}"
}
