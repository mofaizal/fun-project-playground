locals {
  # Common values
  location            = "southeastasia"
  resource_group_name = "rg-vwan-prod"
  virtual_wan_name    = "vwan-prod"
  tags = {
    environment = "production"
    owner       = "team-example"
  }

  # Virtual Hubs Configuration
  virtual_hubs = {
    "prod-vhub" = {
      virtual_hub_key = "prod-vhub"
      name            = "prod-vhub"
      location        = local.location
      resource_group  = local.resource_group_name
      address_prefix  = "10.100.0.0/24"
      tags            = local.tags
    },
    "non-prod-vhub" = {
      virtual_hub_key = "non-prod-vhub"
      name            = "non-prod-vhub"
      location        = local.location
      resource_group  = local.resource_group_name
      address_prefix  = "10.100.1.0/24"
      tags            = local.tags
    },
    "dev-vhub" = {
      virtual_hub_key = "dev-vhub"
      name            = "dev-vhub"
      location        = local.location
      resource_group  = local.resource_group_name
      address_prefix  = "10.100.2.0/24"
      tags            = local.tags
    }
  }

  # Firewall Configuration for each hub
  firewalls = {
    "prod-fw" = {
      firewall_key    = "prod-fw"
      name            = "firewall-1"
      virtual_hub_key = "prod-vhub"
      sku_name        = "AZFW_Hub"
      sku_tier        = "Standard"
    },
    "non-prod-fw" = {
      firewall_key    = "non-prod-fw"
      name            = "firewall-2"
      virtual_hub_key = "non-prod-vhub"
      sku_name        = "AZFW_Hub"
      sku_tier        = "Standard"
    },
    "dev-fw" = {
      firewall_key    = "dev-fw"
      name            = "firewall-3"
      virtual_hub_key = "dev-vhub"
      sku_name        = "AZFW_Hub"
      sku_tier        = "Standard"
    }
  }

  # Routing Intents for each hub
  routing_intents = {
    "prod-vhub-1-routing-intent" = {
      name            = "private-routing-intent-1"
      virtual_hub_key = "prod-vhub"
      routing_policies = [{
        name                  = "vhub-1-routing-policy-private"
        destinations          = ["PrivateTraffic"]
        next_hop_firewall_key = "prod-fw"
      }]
    },
    "non-prod-vhub-2-routing-intent" = {
      name            = "private-routing-intent-2"
      virtual_hub_key = "non-prod-vhub"
      routing_policies = [{
        name                  = "vhub-2-routing-policy-private"
        destinations          = ["PrivateTraffic"]
        next_hop_firewall_key = "non-prod-fw"
      }]
    },
    "dev-vhub-3-routing-intent" = {
      name            = "private-routing-intent-3"
      virtual_hub_key = "dev-vhub"
      routing_policies = [{
        name                  = "vhub-3-routing-policy-private"
        destinations          = ["PrivateTraffic"]
        next_hop_firewall_key = "dev-fw"
      }]
    }
  }
}
