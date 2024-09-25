# Reference the vWAN outputs from the previous state
data "terraform_remote_state" "vwan" {
  backend = "local" # Change as per your backend configuration
  config = {
    path = "/home/faizal/fun-project-playground/avm-vwan/prod/terraform.tfstate" # This should point to the saved vWAN state file
  }
}

# Create Production Secure Hub
module "prod_vhub" {
  source                         = "Azure/avm-ptn-virtualwan/azurerm"
  version                        = "0.5.0"
  create_resource_group          = true
  resource_group_name            = local.prod_resource_group_name
  location                       = local.location
  virtual_wan_name               = local.prod_resource_group_name //data.terraform_remote_state.vwan.outputs.vwan_name
  disable_vpn_encryption         = false
  allow_branch_to_branch_traffic = true
  type                           = "Standard"
  virtual_wan_tags               = local.tags

  virtual_hubs = {
    "prod-vhub" = {
      name           = local.prod_vhub_name
      location       = local.location
      resource_group = local.prod_resource_group_name
      address_prefix = "10.1.0.0/24"
      tags           = local.tags
    }
  }

  firewalls = {
    "prod-fw" = {
      sku_name        = "AZFW_Hub"
      sku_tier        = "Standard"
      name            = local.prod_firewall_name
      virtual_hub_key = "prod-vhub"
    }
  }

  routing_intents = {
    "prod-vhub-routing-intent" = {
      name            = "prod-routing-intent"
      virtual_hub_key = "prod-vhub"
      routing_policies = [{
        name                  = "prod-routing-policy"
        destinations          = ["PrivateTraffic"]
        next_hop_firewall_key = "prod-fw"
      }]
    }
  }
}
