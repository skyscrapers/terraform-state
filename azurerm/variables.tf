variable "project" {
  description = "Project name"
}

variable "location" {
  description = "Azure region where to deploy the storage account"
}

variable "tags" {
  description = "Additional tags to add to the created resources"
  default     = {}
}
