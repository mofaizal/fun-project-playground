# Create Virtual WAN with Virtual Hubs, Firewalls, and Routing Intents
module "vwan_with_vhub" {
  source                         = "Azure/avm-ptn-virtualwan/azurerm"
  version                        = "0.5.0"
  create_resource_group          = true
  resource_group_name            = local.resource_group_name
  location                       = local.location
  virtual_wan_name               = local.virtual_wan_name
  disable_vpn_encryption         = false
  allow_branch_to_branch_traffic = true
  type                           = "Standard"
  virtual_wan_tags               = local.tags

  virtual_hubs = local.virtual_hubs

  firewalls = local.firewalls

  routing_intents = local.routing_intents
}
