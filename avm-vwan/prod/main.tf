# vwan.tf
# Create a Virtual WAN
module "vwan" {
  source                         = "Azure/avm-ptn-virtualwan/azurerm"
  version                        = "0.5.0"
  create_resource_group          = true
  resource_group_name            = local.vwan_resource_group_name
  location                       = local.location
  virtual_wan_name               = local.virtual_wan_name
  disable_vpn_encryption         = false
  allow_branch_to_branch_traffic = true
  type                           = "Standard"
  virtual_wan_tags               = local.vwan_tags
}


