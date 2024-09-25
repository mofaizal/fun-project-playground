<!-- BEGIN_TF_DOCS -->
<!-- BEGIN\_TF\_DOCS -->
> [!IMPORTANT]
[!IMPORTANT]
> This script utilizes the Azure Verified Modules (AVM) and can be leveraged in all types of environments (e.g., development, testing, production, etc.). The input parameters provided in this repository are examples only. Anyone referring to this repository should carefully review their specific needs and adjust the parameters accordingly to meet their requirements.

> The author assumes no responsibility for any breaking changes that may occur. Any feedback or issues related to the AVM should be reported to the respective module's GitHub repository.
>

```hcl
# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

locals {
  custom_landing_zones_combined = merge(
    local.custom_landing_zones,               # From setting.core.tf
    local.custom_landing_zones_prod_unit,     # From setting.core.prod.tf
    local.custom_landing_zones_non_prod_unit, # From setting.core.non-prod.tf
    local.custom_landing_zones_dev_unit       # From setting.core.dev.tf 
  )
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.1.0"

  default_location = "southeastasia"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name

  #custom policy
  library_path = "${path.root}/lib"

  custom_landing_zones = local.custom_landing_zones_combined

}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>=1.5.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.107)

## Resources

The following resources are used by this module:

- [azurerm_client_config.core](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_AzureTenantId"></a> [AzureTenantId](#input\_AzureTenantId)

Description: Azure Tenant Id

Type: `string`

### <a name="input_RootManagementGroupAzureSPNAppId"></a> [RootManagementGroupAzureSPNAppId](#input\_RootManagementGroupAzureSPNAppId)

Description: Root Management Group Azure Service Principle App Id

Type: `string`

### <a name="input_RootManagementGroupAzureSPNPwd"></a> [RootManagementGroupAzureSPNPwd](#input\_RootManagementGroupAzureSPNPwd)

Description: Root Management Group Azure  Service Principle Password

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_connectivity_display_name"></a> [connectivity\_display\_name](#input\_connectivity\_display\_name)

Description: n/a

Type: `string`

Default: `"Your Root Managment Group Name"`

### <a name="input_connectivity_resources_location"></a> [connectivity\_resources\_location](#input\_connectivity\_resources\_location)

Description: n/a

Type: `string`

Default: `"southeastasia"`

### <a name="input_connectivity_resources_tags"></a> [connectivity\_resources\_tags](#input\_connectivity\_resources\_tags)

Description: n/a

Type: `map(string)`

Default:

```json
{
  "demo_type": "deploy_connectivity_resources_custom"
}
```

### <a name="input_deploy_connectivity_resources"></a> [deploy\_connectivity\_resources](#input\_deploy\_connectivity\_resources)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_deploy_identity_resources"></a> [deploy\_identity\_resources](#input\_deploy\_identity\_resources)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_deploy_management_resources"></a> [deploy\_management\_resources](#input\_deploy\_management\_resources)

Description: n/a

Type: `bool`

Default: `true`

### <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days)

Description: n/a

Type: `number`

Default: `50`

### <a name="input_management_resources_location"></a> [management\_resources\_location](#input\_management\_resources\_location)

Description: n/a

Type: `string`

Default: `"southeastasia"`

### <a name="input_management_resources_tags"></a> [management\_resources\_tags](#input\_management\_resources\_tags)

Description: n/a

Type: `map(string)`

Default:

```json
{
  "demo_type": "deploy_management_resources_custom"
}
```

### <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location)

Description: Sets the location for "primary" resources to be created in.

Type: `string`

Default: `"southeastasia"`

### <a name="input_root_id"></a> [root\_id](#input\_root\_id)

Description: n/a

Type: `string`

Default: `"au-ism"`

### <a name="input_root_name"></a> [root\_name](#input\_root\_name)

Description: n/a

Type: `string`

Default: `"Your Root Managment Group Name"`

### <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location)

Description: Sets the location for "secondary" resources to be created in.

Type: `string`

Default: `"eastasia"`

### <a name="input_security_alerts_email_address"></a> [security\_alerts\_email\_address](#input\_security\_alerts\_email\_address)

Description: n/a

Type: `string`

Default: `"my_valid_security_contact@replace_me"`

### <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity)

Description: Subscription ID to use for "connectivity" resources.

Type: `string`

Default: `""`

### <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity)

Description: Subscription ID to use for "identity" resources.

Type: `string`

Default: `""`

### <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management)

Description: Subscription ID to use for "management" resources.

Type: `string`

Default: `""`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_enterprise_scale"></a> [enterprise\_scale](#module\_enterprise\_scale)

Source: Azure/caf-enterprise-scale/azurerm

Version: 6.1.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

AVM collect information about you and your use for more details refer to https://azure.github.io/Azure-Verified-Modules/
<!-- END_TF_DOCS -->