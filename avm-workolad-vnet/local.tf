locals {

  resource_group_name = "rg-avm-workload-a"
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
    "apptier" = {
      name             = "appsubnet"
      address_prefixes = "10.201.2.0/24"
    },
    "dbtier" = {
      name             = "dbsubnet"
      address_prefixes = "10.201.3.0/24"
    },
  }

}
