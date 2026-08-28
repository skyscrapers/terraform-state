output "bucket_id" {
  value       = aws_s3_bucket.state.id
  description = "Id (name) of the S3 bucket"
}

output "tf_policy_name" {
  value       = aws_iam_policy.tf.name
  description = "The name of the policy for Terraform users to access the state and S3-native lock files"
}

output "tf_policy_arn" {
  value       = aws_iam_policy.tf.arn
  description = "The ARN of the policy for Terraform users to access the state and S3-native lock files"
}

output "tf_policy_id" {
  value       = aws_iam_policy.tf.id
  description = "The ID of the policy for Terraform users to access the state and S3-native lock files"
}

output "replica_bucket_id" {
  value       = one(aws_s3_bucket.replica[*].id)
  description = "Id (name) of the replica S3 bucket, null when replication is disabled"
}

output "replica_bucket_arn" {
  value       = one(aws_s3_bucket.replica[*].arn)
  description = "ARN of the replica S3 bucket, null when replication is disabled"
}

output "replication_role_arn" {
  value       = one(aws_iam_role.replication[*].arn)
  description = "ARN of the IAM role S3 assumes to replicate the state bucket, null when replication is disabled"
}

output "replication_metric_dimensions" {
  value = local.replication_enabled == 0 ? null : {
    SourceBucket      = aws_s3_bucket.state.id
    DestinationBucket = one(aws_s3_bucket.replica[*].id)
    RuleId            = one(aws_s3_bucket_replication_configuration.state[*].rule[0].id)
  }
  description = "Dimensions (SourceBucket, DestinationBucket, RuleId) for the AWS/S3 replication CloudWatch metrics (OperationsFailedReplication, OperationsPendingReplication, BytesPendingReplication, ReplicationLatency), null when replication is disabled. The metrics only report data once replication.metrics (or replication_time) is on."
}
