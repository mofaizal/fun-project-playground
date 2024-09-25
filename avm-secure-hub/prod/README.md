<!-- BEGIN_TF_DOCS -->
<!-- BEGIN\_TF\_DOCS -->
> [!IMPORTANT]
[!IMPORTANT]
> This script utilizes the Azure Verified Modules (AVM) and can be leveraged in all types of environments (e.g., development, testing, production, etc.). The input parameters provided in this repository are examples only. Anyone referring to this repository should carefully review their specific needs and adjust the parameters accordingly to meet their requirements.

> The author assumes no responsibility for any breaking changes that may occur. Any feedback or issues related to the AVM should be reported to the respective module's GitHub repository.
>

```hcl
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.7)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.108)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

## Resources

The following resources are used by this module:

- [terraform_remote_state.vwan](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_prod_vhub"></a> [prod\_vhub](#module\_prod\_vhub)

Source: Azure/avm-ptn-virtualwan/azurerm

Version: 0.5.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

AVM collect information about you and your use for more details refer to https://azure.github.io/Azure-Verified-Modules/
<!-- END_TF_DOCS -->