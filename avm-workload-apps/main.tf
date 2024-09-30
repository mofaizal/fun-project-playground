# This is the module call

data "terraform_remote_state" "vnet" {
  backend = "local" # Change as per your backend configuration
  config = {
    path = "../avm-workload-vnet/terraform.tfstate" # This should point to the saved vWAN state file
  }
}

locals {
  #   #   vnet_id_parts       = split("/", data.terraform_remote_state.vnet.outputs.vnet_id)
  #   #   resource_group_name = local.vnet_id_parts[4] # 5th element is the resource group name
  #   vnet_id_parts       = split("/", data.terraform_remote_state.vnet.resources[0].instances[0].attributes.id)
  #   resource_group_name = local.vnet_id_parts[4]

  #   location        = data.terraform_remote_state.vnet.outputs.location
  #   subnet_id_parts = split("/", data.terraform_remote_state.vnet.outputs.subnet_id)
  #   subnet_id       = local.subnet_id_parts[10]

  tags = {
    scenario = "VMSS Autoscale Linux AVM Sample"
  }
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
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
  #enable_telemetry    = var.enable_telemetry
  location                    = data.terraform_remote_state.vnet.outputs.location
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
    # network_security_group_id = azurerm_network_security_group.nic.id
    ip_configuration = [{
      name                                    = "VMSS-IPConfig"
      subnet_id                               = data.terraform_remote_state.vnet.outputs.subnet_all.webtier.resource_id
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
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name
}

output "private_ip_addresses" {
  value = flatten([for instance in data.azurerm_virtual_machine_scale_set.private_ip_address.instances : instance.private_ip_address])
}

module "loadbalancer" {
  source              = "Azure/avm-res-network-loadbalancer/azurerm"
  version             = "0.2.2"
  name                = "internal-lb"
  location            = data.terraform_remote_state.vnet.outputs.location
  resource_group_name = data.terraform_remote_state.vnet.outputs.resource_group_name

  # Virtual Network and Subnet for Internal LoadBalancer
  # frontend_vnet_resource_id   = azurerm_virtual_network.example.id
  frontend_subnet_resource_id = data.terraform_remote_state.vnet.outputs.subnet_all.webtier.resource_id

  # Frontend IP Configuration
  frontend_ip_configurations = {
    frontend_configuration_1 = {
      name                                   = "myFrontend"
      frontend_private_ip_subnet_resource_id = data.terraform_remote_state.vnet.outputs.subnet_all.webtier.resource_id
      # zones = ["1", "2", "3"] # Zone-redundant
      # zones = ["None"] # Non-zonal
    }
  }

  # Backend Address Pool
  backend_address_pools = {
    pool1 = {
      name = "myBackendPool"
    }
  }

  backend_address_pool_addresses = {
    address1 = {
      name                             = "vmss1" # must be unique if multiple addresses are used
      backend_address_pool_object_name = "pool1"
      ip_address                       = data.azurerm_virtual_machine_scale_set.private_ip_address.instances[0].private_ip_address
      virtual_network_resource_id      = data.terraform_remote_state.vnet.outputs.vnet_id.vnet.resource_id
    }
    address2 = {
      name                             = "vmss2" # must be unique if multiple addresses are used
      backend_address_pool_object_name = "pool1"
      ip_address                       = data.azurerm_virtual_machine_scale_set.private_ip_address.instances[1].private_ip_address
      virtual_network_resource_id      = data.terraform_remote_state.vnet.outputs.vnet_id.vnet.resource_id
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

      probe_object_name = "tcp1"
      //backend_address_pool_id = azurerm_lb_backend_address_pool.app_lb_backend_address_pool.id 
      idle_timeout_in_minutes = 15
      enable_tcp_reset        = true
    }
  }
}

