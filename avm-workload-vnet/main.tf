#create resource group

module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.1.0"
  name     = local.resource_group_name
  location = local.location
}

#create virtual network
module "pv-resolver-virtualnetwork" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.4.0"
  for_each            = local.virtual_network
  address_space       = [each.value.address_space]
  location            = local.location
  name                = each.value.name
  resource_group_name = local.resource_group_name

  depends_on = [module.resource_group]
}

module "subnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"

  virtual_network = {
    resource_id = module.pv-resolver-virtualnetwork["vnet"].resource_id
  }
  for_each         = local.subnet
  name             = each.value.name
  address_prefixes = [each.value.address_prefixes]
  depends_on       = [module.pv-resolver-virtualnetwork]
}

module "nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  for_each            = local.subnet
  name                = each.value.nsg_name
  resource_group_name = local.resource_group_name
  location            = local.location
  security_rules      = local.nsg_rules
}

# Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "ag_subnet_nsg_associate" {
  for_each                  = local.subnet
  network_security_group_id = module.nsg[each.key].resource_id
  # Every NSG Rule Association will disassociate NSG from Subnet and Associate it, so we associate it only after NSG is completely created 
  #- Azure Provider Bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/354  
  subnet_id = module.subnet[each.key].resource_id
}

