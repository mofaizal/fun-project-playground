module "avm-res-network-dnsresolver" {
  source                      = "Azure/avm-res-network-dnsresolver/azurerm"
  version                     = "0.2.1"
  resource_group_name         = local.resource_group_name
  name                        = "pv-resolver-prod-sea"
  virtual_network_resource_id = module.pv-resolver-virtualnetwork["vnet"].resource_id
  location                    = local.location
  inbound_endpoints = {
    "inbound" = {
      name        = "inbound"
      subnet_name = module.subnet["inbound"].name

    }
  }
  outbound_endpoints = {
    "outbound1" = {
      name        = "outbound1"
      subnet_name = module.subnet["outbound"].name
      forwarding_ruleset = {
        "ruleset1" = {
          name = "ruleset1"
          rules = {
            "rule1" = {
              name        = "rule1"
              domain_name = "example.com."
              state       = "Enabled"
              destination_ip_addresses = {
                "10.1.1.1" = "53"
                "10.1.1.2" = "53"
              }
            },
            "rule2" = {
              name        = "rule2"
              domain_name = "example2.com."
              state       = "Enabled"
              destination_ip_addresses = {
                "10.2.2.2" = "53"
              }
            }
          }
        }
      }
    }
    "outbound2" = {
      name        = "outbound2"
      subnet_name = module.subnet["outbound2"].name
    }
  }
}
