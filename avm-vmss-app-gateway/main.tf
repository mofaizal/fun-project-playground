# We need the tenant id for the key vault.
data "azurerm_client_config" "this" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
}











