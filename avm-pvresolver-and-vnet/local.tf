locals {

  resource_group_name = "rg-avm-dns-reslover-prod"
  location            = "southeastasia"

  virtual_network = {
    vnet = {
      name          = "dnsreslover-vnet"
      address_space = "10.200.0.0/16"
    }
  }

  subnet = {
    "inbound" = {
      name             = "inbound-resolver-subnet"
      address_prefixes = "10.200.1.0/24"
    },
    "outbound" = {
      name             = "outbound-resolver-subnet"
      address_prefixes = "10.200.2.0/24"
    },
    "outbound2" = {
      name             = "outbound-resolver-subnet2"
      address_prefixes = "10.200.3.0/24"
    },
  }

}
