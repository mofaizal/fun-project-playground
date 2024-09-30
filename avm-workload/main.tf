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





