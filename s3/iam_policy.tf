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

  # DeleteObject is scoped so the real state objects stay immutable, while
  # the two cases that legitimately delete can:
  # - *.tflock: with use_lockfile, unlock deletes the <key>.tflock object.
  # - env:/default-plan/*: the Concourse terragrunt-resource stashes plan
  #   files in a "default-plan" workspace (the env:/ prefix) and removes
  #   them after applying. Real Terragrunt state lives at the bare key (no
  #   workspaces), so it remains undeletable.
  statement {
    actions = [
      "s3:DeleteObject",
    ]

    resources = [
      "${aws_s3_bucket.state.arn}/*.tflock",
      "${aws_s3_bucket.state.arn}/env:/default-plan/*",
    ]
  }
}

resource "aws_iam_policy" "tf" {
  name        = "terraform-remote-state-${var.project}"
  description = "Policy for Terraform users to access the state and S3-native lock files"
  policy      = data.aws_iam_policy_document.tf.json
}
