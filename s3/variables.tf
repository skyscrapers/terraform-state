variable "project" {
  description = "Project name"
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
