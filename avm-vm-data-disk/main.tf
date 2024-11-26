#create resource group
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
}


module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.1.0"
  name     = module.naming.resource_group.name_unique
  location = local.location
}

#create virtual network
module "virtualnetwork" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.4.0"
  for_each            = local.virtual_network
  address_space       = [each.value.address_space]
  location            = local.location
  name                = each.value.name
  resource_group_name = module.resource_group.name

  depends_on = [module.resource_group]
}

module "subnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"

  virtual_network = {
    resource_id = module.virtualnetwork["vnet"].resource_id
  }
  for_each         = local.subnet
  name             = each.value.name
  address_prefixes = [each.value.address_prefixes]
  depends_on       = [module.virtualnetwork]
}

module "publicipaddress" {
  source              = "Azure/avm-res-network-publicipaddress/azurerm"
  version             = "0.1.2"
  resource_group_name = module.resource_group.name
  name                = module.naming.public_ip.name_unique
  location            = local.location
  depends_on          = [module.resource_group]
}

# # To test and ensure that the disk is attached to the VM. 
# # otherwise this module not required. 
# module "azure_bastion" {
#   source  = "Azure/avm-res-network-bastionhost/azurerm"
#   version = "0.3.0"


#   name                = "bastionhost"
#   resource_group_name = module.resource_group.name
#   location            = local.location
#   copy_paste_enabled  = true
#   file_copy_enabled   = false
#   sku                 = "Standard"
#   ip_configuration = {
#     name                 = "my-ipconfig"
#     subnet_id            = module.subnet["AzureBastionSubnet"].resource_id
#     public_ip_address_id = module.publicipaddress.public_ip_id
#   }
#   ip_connect_enabled     = true
#   scale_units            = 4
#   shareable_link_enabled = true
#   tunneling_enabled      = true
#   kerberos_enabled       = true

#   depends_on = [module.subnet, module.publicipaddress]
# }

module "azure_linux_virtual_machine" {

  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.15.1"

  admin_username                     = "azureuser"
  admin_password                     = "YourComplex_P@ssword1234"
  disable_password_authentication    = false
  encryption_at_host_enabled         = false
  generate_admin_password_or_ssh_key = false
  location                           = local.location
  name                               = "VM"
  resource_group_name                = module.resource_group.name
  os_type                            = "Linux"
  sku_size                           = "Standard_D2s_v3"
  zone                               = "1"

  network_interfaces = {
    network_interface_1 = {
      name = "Nic"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "Nic-ipconfig1"
          private_ip_subnet_resource_id = module.subnet["webtier"].resource_id
        }
      }
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  custom_data = filebase64("cloud-init.yml")
  depends_on  = [module.resource_group, module.subnet]
}

module "data_disk_1" {
  source                = "Azure/avm-res-compute-disk/azurerm"
  version               = "0.2.2"
  for_each              = local.disk
  location              = local.location
  resource_group_name   = module.resource_group.name
  name                  = each.value.name
  zone                  = each.value.zone
  create_option         = each.value.create_option
  storage_account_type  = each.value.storage_account_type
  disk_size_gb          = each.value.disk_size_gb
  network_access_policy = each.value.network_access_policy
  depends_on            = [module.resource_group]
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment" {
  count              = length(local.disk) # Assuming it's a list
  managed_disk_id    = module.data_disk_1[count.index].resource_id
  virtual_machine_id = module.azure_linux_virtual_machine.virtual_machine.id
  lun                = count.index
  caching            = "ReadWrite"
}
