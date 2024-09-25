# local.tf for vWAN

locals {
  location                 = "southeastasia"
  vwan_resource_group_name = "rg-vwan-main"
  virtual_wan_name         = "central-vwan"
  vwan_tags = {
    environment = "central"
    owner       = "team-network"
  }
}
