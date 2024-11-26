resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "keyvault-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = module.virtualnetwork["vnet"].resource_id
}
