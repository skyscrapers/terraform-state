output "bucket-id" {
  value = "${module.state-bucket.id}"
}

output "locktable-id" {
  value = "${aws_dynamodb_table.terraform-state-locktable.id}"
}