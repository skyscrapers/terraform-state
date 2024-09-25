output "bucket_id" {
  value       = aws_s3_bucket.state.id
  description = "Id (name) of the S3 bucket"
}

output "locktable_id" {
  value       = aws_dynamodb_table.terraform_state_locktable.id
  description = "Id (name) of the DynamoDB lock table"
}

output "tf_policy_name" {
  value       = aws_iam_policy.tf.name
  description = "The name of the policy for Terraform users to access the state and lock table"
}

output "tf_policy_arn" {
  value       = aws_iam_policy.tf.arn
  description = "The ARN of the policy for Terraform users to access the state and lock table"
}

output "tf_policy_id" {
  value       = aws_iam_policy.tf.id
  description = "The ID of the policy for Terraform users to access the state and lock table"
}
