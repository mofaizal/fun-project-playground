#publiips for all
resource "azurerm_public_ip" "publi_ips" {
  name                = "bastion-pip"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#bastion host
resource "azurerm_bastion_host" "example" {
  name                = "bastion"
  location            = local.location
  resource_group_name = local.resource_group_name
  ip_configuration {
    name                 = "ipconfig"
    public_ip_address_id = azurerm_public_ip.publi_ips.id
    subnet_id            = module.subnet["AzureBastionSubnet"].resource_id

  }
  depends_on = [module.subnet]
}
