terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.14"
    }
  }
}

provider "azurerm" {
  features {}
}
