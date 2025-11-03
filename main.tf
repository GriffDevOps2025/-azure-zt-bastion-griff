# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Random suffix for unique names
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}