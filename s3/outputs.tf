output "bucket_id" {
  value = "${join("", aws_s3_bucket.state.*.id)}"
}

output "locktable_id" {
  value = "${join("", aws_dynamodb_table.terraform-state-locktable.*.id)}"
}
