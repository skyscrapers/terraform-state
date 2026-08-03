terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"

      # The replica bucket is created with this provider, so it decides in
      # which region and account the replica lands. Alias it to the primary
      # provider when replication is disabled.
      configuration_aliases = [aws.replica]
    }
  }
}
