# local.tf for production hub

locals {
  location                 = "southeastasia"
  prod_resource_group_name = "rg-prod-hub"
  prod_vhub_name           = "prod-vhub"
  prod_firewall_name       = "prod-firewall"
  tags = {
    environment = "production"
    owner       = "team-prod"
  }
}

