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
    ]

    resources = ["${aws_s3_bucket.state.arn}/*"]
  }

  # DeleteObject is scoped to lock files only. With use_lockfile, unlock
  # deletes the <key>.tflock object; OpenTofu never deletes state objects
  # (workspace deletion would, but Terragrunt does not use workspaces).
  statement {
    actions = [
      "s3:DeleteObject",
    ]

    resources = ["${aws_s3_bucket.state.arn}/*.tflock"]
  }
}

resource "aws_iam_policy" "tf" {
  name        = "terraform-remote-state-${var.project}"
  description = "Policy for Terraform users to access the state and S3-native lock files"
  policy      = data.aws_iam_policy_document.tf.json
}
