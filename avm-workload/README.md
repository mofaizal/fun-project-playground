<!-- BEGIN_TF_DOCS -->
<!-- BEGIN\_TF\_DOCS -->
> [!IMPORTANT]
[!IMPORTANT]
> This script utilizes the Azure Verified Modules (AVM) and can be leveraged in all types of environments (e.g., development, testing, production, etc.). The input parameters provided in this repository are examples only. Anyone referring to this repository should carefully review their specific needs and adjust the parameters accordingly to meet their requirements.

> The author assumes no responsibility for any breaking changes that may occur. Any feedback or issues related to the AVM should be reported to the respective module's GitHub repository.
>

### Creating VNET, Subnet, NSG, NSG Rule,Associating NSG to Subnet, VM Scale Set and Load Balancer as Layer

### Architecture Overview

The proposed architecture involves creating a virtual network (VNET) in Azure, along with subnets within that VNET. Network security groups (NSGs) are then defined to control network traffic in and out of these subnets. NSG rules (sample) are configured within the NSGs to specify the allowed or denied traffic. NSGs are associated with the respective subnets Finally, the create VM Scale set and Load Balancer

![](../images/vnet.png)

### Terraform Script and Azure Verify Module

Terraform script to automate the creation of these resources. The Azure Verify Module can be used to validate the configuration of these resources against predefined rules and best practices. This ensures that the deployed infrastructure aligns with your desired security and compliance requirements.

### Additional Considerations

**State Management:** The state management for this layer is separate. Ensure that your Terraform configuration properly handles state management, such as using a remote backend or a suitable state storage mechanism.

**Best Practices:** Follow Azure best practices for VNET, subnet, NSG, and NSG rule configuration. This includes using appropriate naming conventions, considering subnet size and addressing, and applying granular security policies.

**Testing and Validation:** Thoroughly test your Terraform script to ensure it creates the desired resources correctly. Use tools like Terraform plan and Terraform apply to preview and execute changes. Consider using Azure Verify Module to validate the deployed resources against best practices.

```hcl
#create resource group

module "resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.1.0"
  name     = local.resource_group_name
  location = local.location
}

#create virtual network
module "virtualnetwork" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.4.0"
  for_each            = local.virtual_network
  address_space       = [each.value.address_space]
  location            = local.location
  name                = each.value.name
  resource_group_name = local.resource_group_name

  depends_on = [module.resource_group]
}

module "subnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"

  virtual_network = {
    resource_id = module.virtualnetwork["vnet"].resource_id
  }
  for_each         = local.subnet
  name             = each.value.name
  address_prefixes = [each.value.address_prefixes]
  depends_on       = [module.virtualnetwork]
}

module "nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  for_each            = toset(local.nsg_name)
  name                = each.key
  resource_group_name = local.resource_group_name
  location            = local.location
  security_rules      = local.nsg_rules
}

# Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "ag_subnet_nsg_associate" {
  network_security_group_id = module.nsg["websubnet-nsg"].resource_id
  # Every NSG Rule Association will disassociate NSG from Subnet and Associate it, so we associate it only after NSG is completely created 
  #- Azure Provider Bug https://github.com/terraform-providers/terraform-provider-azurerm/issues/354  
  subnet_id = module.subnet.webtier.resource_id

}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
}

resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "terraform_azurerm_avm_res_compute_virtualmachinescaleset" {
  source              = "Azure/avm-res-compute-virtualmachinescaleset/azurerm"
  version             = "0.3.0"
  name                = module.naming.virtual_machine_scale_set.name_unique
  resource_group_name = local.resource_group_name
  #enable_telemetry    = var.enable_telemetry
  location                    = local.location
  admin_password              = "P@ssw0rd1234!"
  instances                   = 2
  sku_name                    = "Standard_DS1_v2"
  extension_protected_setting = {}
  user_data_base64            = null
  boot_diagnostics = {
    storage_account_uri = "" # Enable boot diagnostics
  }
  admin_ssh_keys = [(
    {
      id         = tls_private_key.example_ssh.id
      public_key = tls_private_key.example_ssh.public_key_openssh
      username   = "azureuser"
    }
  )]
  network_interface = [{
    name = "VMSS-NIC"

    ip_configuration = [{
      name                                    = "VMSS-IPConfig"
      subnet_id                               = module.subnet["webtier"].resource_id
      load_balancer_backend_address_pools_ids = [module.loadbalancer.azurerm_lb.id]
    }]
  }]
  os_profile = {
    custom_data = base64encode(local.webvm_custom_data)
    linux_configuration = {
      disable_password_authentication = false
      #   user_data_base64                = base64encode(file("user-data.sh"))
      admin_username = "azureuser"
      admin_ssh_key  = toset([tls_private_key.example_ssh.id])
    }
  }
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS-gen2" # Auto guest patching is enabled on this sku.  https://learn.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching
    version   = "latest"
  }
  extension = [{
    name                        = "HealthExtension"
    publisher                   = "Microsoft.ManagedServices"
    type                        = "ApplicationHealthLinux"
    type_handler_version        = "1.0"
    auto_upgrade_minor_version  = true
    failure_suppression_enabled = false
    settings                    = "{\"port\":80,\"protocol\":\"http\",\"requestPath\":\"/index.html\"}"
  }]
  tags = local.tags

}

data "azurerm_virtual_machine_scale_set" "private_ip_address" {
  name                = module.naming.virtual_machine_scale_set.name_unique
  resource_group_name = local.resource_group_name
}

output "private_ip_addresses" {
  value = flatten([for instance in data.azurerm_virtual_machine_scale_set.private_ip_address.instances : instance.private_ip_address])
}


module "loadbalancer" {
  source              = "Azure/avm-res-network-loadbalancer/azurerm"
  version             = "0.2.2"
  name                = "internal-lb"
  location            = local.location
  resource_group_name = local.resource_group_name

  # Virtual Network and Subnet for Internal LoadBalancer
  # frontend_vnet_resource_id   = azurerm_virtual_network.example.id
  frontend_subnet_resource_id = module.subnet["webtier"].resource_id

  # Frontend IP Configuration
  frontend_ip_configurations = {
    frontend_configuration_1 = {
      name                                   = "myFrontend"
      frontend_private_ip_subnet_resource_id = module.subnet["webtier"].resource_id
      # zones = ["1", "2", "3"] # Zone-redundant
      # zones = ["None"] # Non-zonal
    }
  }
  # Backend Address Pool
  backend_address_pools = {
    pool1 = {
      name            = "myBackendPool"
      loadbalancer_id = module.loadbalancer.azurerm_lb.id
    }
  }

  backend_address_pool_addresses = {
    address1 = {
      name                             = "myBackendPool1" # must be unique if multiple addresses are used
      backend_address_pool_object_name = "pool1"
      ip_address                       = data.azurerm_virtual_machine_scale_set.private_ip_address.instances[0].private_ip_address
      virtual_network_resource_id      = module.virtualnetwork["vnet"].resource_id
    }
    address2 = {
      name                             = "myBackendPool2" # must be unique if multiple addresses are used
      backend_address_pool_object_name = "pool1"
      ip_address                       = data.azurerm_virtual_machine_scale_set.private_ip_address.instances[1].private_ip_address
      virtual_network_resource_id      = module.virtualnetwork["vnet"].resource_id
    }
  }



  # Health Probe(s)
  lb_probes = {
    tcp1 = {
      name     = "myHealthProbe"
      protocol = "Tcp"
    }
  }

  # Load Balaner rule(s)
  lb_rules = {
    http1 = {
      name                           = "myHTTPRule"
      frontend_ip_configuration_name = "myFrontend"

      backend_address_pool_object_names = ["pool1"]
      protocol                          = "Tcp"
      frontend_port                     = 80
      backend_port                      = 80
      //backend_address_pool_id           = "/subscriptions/acf4d45f-adcb-4d8b-95e7-a980b37d9b6b/resourceGroups/rg-avm-workload-a/providers/Microsoft.Network/loadBalancers/internal-lb/backendAddressPools/myBackendPool"
      probe_object_name       = "tcp1"
      idle_timeout_in_minutes = 15
      enable_tcp_reset        = true
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

- [azurerm_subnet_network_security_group_association.ag_subnet_nsg_associate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) (resource)
- [tls_private_key.example_ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)
- [azurerm_virtual_machine_scale_set.private_ip_address](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_machine_scale_set) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_location"></a> [location](#output\_location)

Description: n/a

### <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses)

Description: n/a

### <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name)

Description: n/a

### <a name="output_subnet_all"></a> [subnet\_all](#output\_subnet\_all)

Description: n/a

### <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_loadbalancer"></a> [loadbalancer](#module\_loadbalancer)

Source: Azure/avm-res-network-loadbalancer/azurerm

Version: 0.2.2

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.1

### <a name="module_nsg"></a> [nsg](#module\_nsg)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.2.0

### <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group)

Source: Azure/avm-res-resources-resourcegroup/azurerm

Version: 0.1.0

### <a name="module_subnet"></a> [subnet](#module\_subnet)

Source: Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet

Version:

### <a name="module_terraform_azurerm_avm_res_compute_virtualmachinescaleset"></a> [terraform\_azurerm\_avm\_res\_compute\_virtualmachinescaleset](#module\_terraform\_azurerm\_avm\_res\_compute\_virtualmachinescaleset)

Source: Azure/avm-res-compute-virtualmachinescaleset/azurerm

Version: 0.3.0

### <a name="module_virtualnetwork"></a> [virtualnetwork](#module\_virtualnetwork)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: 0.4.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

AVM collect information about you and your use for more details refer to https://azure.github.io/Azure-Verified-Modules/
<!-- END_TF_DOCS -->