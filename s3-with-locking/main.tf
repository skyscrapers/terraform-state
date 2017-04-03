module "state-bucket" {
  source = "../s3/"
  environment = "${var.environment}"
  project = "${var.project}"
}

resource "aws_dynamodb_table" "terraform-state-locktable" {
  name           = "terraform-state-lock-${var.project}-${var.environment}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name        = "terraform-state-lock-${var.project}-${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}