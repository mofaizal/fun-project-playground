locals {

  resource_group_name = "rg-avm-workload-b"
  location            = "southeastasia"

  virtual_network = {
    vnet = {
      name          = "workload-a-vnet"
      address_space = "10.201.0.0/16"
    }
  }

  subnet = {
    "webtier" = {
      name             = "websubnet"
      address_prefixes = "10.201.1.0/24"
    },
    "AzureBastionSubnet" = {
      name             = "AzureBastionSubnet"
      address_prefixes = "10.201.2.0/24"
    }

  }

  disk = {
    "0" = {
      name                  = "datadisk_0"
      disk_size_gb          = 8
      create_option         = "Empty"
      storage_account_type  = "Standard_LRS"
      network_access_policy = "AllowAll"
      zone                  = 1
    }
    "1" = {
      name                  = "datadisk_1"
      disk_size_gb          = 8
      create_option         = "Empty"
      storage_account_type  = "Standard_LRS"
      network_access_policy = "AllowAll"
      zone                  = 1
    }
  }
}
