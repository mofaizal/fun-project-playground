# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management,
      ]
    }
    azapi = {
      source  = "azure/azapi"
      version = ">=1.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "connectivity"
  client_id       = var.RootManagementGroupAzureSPNAppId
  client_secret   = var.RootManagementGroupAzureSPNPwd
  tenant_id       = var.AzureTenantId
  subscription_id = var.subscription_id_connectivity
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  alias           = "management"
  client_id       = var.RootManagementGroupAzureSPNAppId
  client_secret   = var.RootManagementGroupAzureSPNPwd
  tenant_id       = var.AzureTenantId
  subscription_id = var.subscription_id_management
  features {}
}
