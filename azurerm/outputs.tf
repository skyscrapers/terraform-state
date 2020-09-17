output "resource_group_name" {
  value       = azurerm_resource_group.terraform_backend.name
  description = "Resource group name where the storage account is deployed"
}

output "resource_group_id" {
  value       = azurerm_resource_group.terraform_backend.id
  description = "Resource group ID where the storage account is deployed"
}

output "storage_account_name" {
  value       = azurerm_storage_account.terraform_backend.name
  description = "Storage account name where the Terraform backend should point to"
}

output "storage_account_id" {
  value       = azurerm_storage_account.terraform_backend.id
  description = "Storage account ID where the Terraform backend should point to"
}

output "storage_container_name" {
  value       = azurerm_storage_container.terraform_backend.name
  description = "Storage container name where to put the Terraform state files"
}

output "storage_container_id" {
  value       = azurerm_storage_container.terraform_backend.id
  description = "Storage container ID where to put the Terraform state files"
}
