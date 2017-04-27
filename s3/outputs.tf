output "bucket_id" {
  value = "${aws_s3_bucket.state.id}"
}

output "locktable_id" {
  value = "${aws_dynamodb_table.terraform-state-locktable.id}"
}
