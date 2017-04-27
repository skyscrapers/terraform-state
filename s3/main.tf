resource "aws_s3_bucket" "state" {
  count  = "${var.create_s3_bucket == "true" ? 1 : 0}"
  bucket = "terraform-state-${var.project}${data.template_file.environment_suffix.rendered}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name        = "terraform-state-${var.project}${data.template_file.environment_suffix.rendered}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_s3_bucket_policy" "b" {
  count  = "${var.create_s3_bucket == "true" ? 1 : 0}"
  bucket = "${aws_s3_bucket.state.bucket}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "PutObjPolicy",
  "Statement": [
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.state.arn}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.state.arn}/*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_s3_bucket_policy" "cross_account_bucket_sharing" {
  count  = "${length(var.shared_aws_account_ids) > 0 && var.create_s3_bucket == "true" ? 1 : 0}"
  bucket = "${aws_s3_bucket.state.bucket}"
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "Shared bucket permissions",
         "Effect": "Allow",
         "Principal": {
            "AWS": [ ${join(formatlist("\"arn:aws:iam::%s:root\"", var.shared_aws_account_ids), ",")} ]
         },
         "Action": [
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:GetObject*",
            "s3:PutObject*"
         ],
         "Resource": [
            "${aws_s3_bucket.state.bucket}",
            "${aws_s3_bucket.state.bucket}/*"
         ]
      },
      {

      }
   ]
}
EOF
}

resource "aws_dynamodb_table" "terraform-state-locktable" {
  count          = "${var.create_dynamodb_lock_table == "true" ? 1 : 0}"
  name           = "terraform-state-lock-${var.project}${data.template_file.environment_suffix.rendered}"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name        = "terraform-state-lock-${var.project}${data.template_file.environment_suffix.rendered}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

data "template_file" "environment_suffix" {
  template = "$${suffix}"

  vars {
    suffix = "${length(var.environment) > 0 ? format("-%s", var.environment) : ""}"
  }
}
