locals {
  default_tags = {
    installer = "terraform"
    project   = var.project
  }

  tags = merge(local.default_tags, var.tags)
}

resource "azurerm_resource_group" "terraform_backend" {
  name     = "terraform-remote-state-${var.project}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "terraform_backend" {
  name                     = "tfbackend${var.project}"
  resource_group_name      = azurerm_resource_group.terraform_backend.name
  location                 = azurerm_resource_group.terraform_backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # i.e. Locally-redundant Storage
  access_tier              = "Hot"
  allow_blob_public_access = false
  tags                     = local.tags

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "terraform_backend" {
  name                  = "tf-state"
  storage_account_name  = azurerm_storage_account.terraform_backend.name
  container_access_type = "private"
}
