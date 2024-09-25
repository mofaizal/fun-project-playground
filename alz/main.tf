# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

locals {
  custom_landing_zones_combined = merge(
    local.custom_landing_zones,               # From setting.core.tf
    local.custom_landing_zones_prod_unit,     # From setting.core.prod.tf
    local.custom_landing_zones_non_prod_unit, # From setting.core.non-prod.tf
    local.custom_landing_zones_dev_unit       # From setting.core.dev.tf 
  )
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.1.0"

  default_location = "southeastasia"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name

  #custom policy
  library_path = "${path.root}/lib"

  custom_landing_zones = local.custom_landing_zones_combined

}
