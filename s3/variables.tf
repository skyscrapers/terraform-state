variable "project" {
  description = "Project name"
}

variable "noncurrent_version_expiration_days" {
  description = <<-EOT
    Number of days after which non-current object versions are permanently
    deleted from the state bucket (and its replica, when enabled). Expired
    delete markers are cleaned up too, so keys whose current version was
    deleted disappear once their history has expired. Applies to existing
    objects as well as new ones.
  EOT

  type    = number
  default = 90
}

variable "replication" {
  description = <<-EOT
    Replication of the state bucket to a replica bucket, for disaster recovery.
    When enabled, the module creates the replica bucket with the `aws.replica`
    provider, the IAM role S3 assumes to replicate, and the replication
    configuration on the state bucket. The region and account of the replica are
    those of the `aws.replica` provider, so the same code does cross-region,
    cross-account, or both.
  EOT

  type = object({
    enabled                  = optional(bool, false)
    storage_class            = optional(string, "STANDARD")
    replicate_delete_markers = optional(bool, false)
    metrics                  = optional(bool, true)
    replication_time         = optional(bool, false)
  })

  default = {}
}
