data "aws_iam_policy_document" "tf" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.state.arn}/*"]
  }
}

resource "aws_iam_policy" "tf" {
  name        = "terraform-remote-state-${var.project}"
  description = "Policy for Terraform users to access the state and lock table"
  policy      = data.aws_iam_policy_document.tf.json
}
