locals {
  replication_enabled = var.replication.enabled ? 1 : 0
  replica_bucket_name = "terraform-remote-state-${var.project}-replica"
}

data "aws_caller_identity" "replica" {
  count    = local.replication_enabled
  provider = aws.replica
}

# Replica bucket, in the region and account of the aws.replica provider.
resource "aws_s3_bucket" "replica" {
  count    = local.replication_enabled
  provider = aws.replica
  bucket   = local.replica_bucket_name

  tags = {
    Name    = local.replica_bucket_name
    Project = var.project
  }
}

# Required on the destination of a replication rule.
resource "aws_s3_bucket_versioning" "replica" {
  count    = local.replication_enabled
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  count    = local.replication_enabled
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Disables ACLs, so the replica account owns the replicated objects. This
# replaces the older ObjectOwnerOverrideToBucketOwner setup.
resource "aws_s3_bucket_ownership_controls" "replica" {
  count    = local.replication_enabled
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "replica" {
  count                   = local.replication_enabled
  provider                = aws.replica
  bucket                  = aws_s3_bucket.replica[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "replica" {
  count = local.replication_enabled

  statement {
    sid = "AllowReplicationWrites"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication[0].arn]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.replica[0].arn}/*"]
  }

  statement {
    sid = "AllowReplicationBucketChecks"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication[0].arn]
    }

    actions = [
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.replica[0].arn]
  }
}

resource "aws_s3_bucket_policy" "replica" {
  count    = local.replication_enabled
  provider = aws.replica
  bucket   = aws_s3_bucket.replica[0].id
  policy   = data.aws_iam_policy_document.replica[0].json

  depends_on = [aws_s3_bucket_public_access_block.replica]
}

data "aws_iam_policy_document" "replication_assume_role" {
  count = local.replication_enabled

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "replication" {
  count              = local.replication_enabled
  name               = "terraform-remote-state-${var.project}-replication"
  description        = "Role S3 assumes to replicate the terraform-remote-state-${var.project} bucket"
  assume_role_policy = data.aws_iam_policy_document.replication_assume_role[0].json
}

data "aws_iam_policy_document" "replication" {
  count = local.replication_enabled

  statement {
    sid = "ReadStateBucket"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    sid = "ReadStateObjects"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.state.arn}/*"]
  }

  statement {
    sid = "WriteReplicaObjects"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.replica[0].arn}/*"]
  }
}

resource "aws_iam_role_policy" "replication" {
  count  = local.replication_enabled
  name   = "replication"
  role   = aws_iam_role.replication[0].id
  policy = data.aws_iam_policy_document.replication[0].json
}

resource "aws_s3_bucket_replication_configuration" "state" {
  count  = local.replication_enabled
  bucket = aws_s3_bucket.state.id
  role   = aws_iam_role.replication[0].arn

  rule {
    id       = "replicate-state"
    status   = "Enabled"
    priority = 0

    # Replicate everything: S3 filters match on prefix or tag, so the
    # short-lived *.tflock and plan objects can't be filtered out by suffix.
    filter {}

    delete_marker_replication {
      status = var.replication.replicate_delete_markers ? "Enabled" : "Disabled"
    }

    destination {
      bucket        = aws_s3_bucket.replica[0].arn
      account       = data.aws_caller_identity.replica[0].account_id
      storage_class = var.replication.storage_class
    }
  }

  depends_on = [
    aws_iam_role_policy.replication,
    aws_s3_bucket_policy.replica,
    aws_s3_bucket_versioning.replica,
  ]
}
