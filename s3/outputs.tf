output "bucket_id" {
  description = "Id (name) of the S3 bucket"
  value       = "${join("", aws_s3_bucket.state.*.id)}"
}

output "locktable_id" {
  description = "Id (name) of the DynamoDB lock table"
  value       = "${join("", aws_dynamodb_table.terraform_state_locktable.*.id)}"
}

output "tf_policy_name" {
  value       = "${aws_iam_policy.tf.name}"
  description = "The name of the policy for Terraform users to access the state and lock table"
}

output "tf_policy_arn" {
  value       = "${aws_iam_policy.tf.arn}"
  description = "The ARN of the policy for Terraform users to access the state and lock table"
}

output "tf_policy_id" {
  value       = "${aws_iam_policy.tf.id}"
  description = "The ID of the policy for Terraform users to access the state and lock table"
}
