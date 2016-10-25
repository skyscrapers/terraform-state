resource "aws_s3_bucket" "state" {
  bucket = "terraform-state-${var.project}-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name        = "terraform-state-${var.project}-${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_s3_bucket_policy" "b" {
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
