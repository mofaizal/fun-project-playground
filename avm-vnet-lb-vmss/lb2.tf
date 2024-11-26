data "azurerm_virtual_machine_scale_set" "private_ip_address_app2" {
  name                = "app2-vmss"
  resource_group_name = local.resource_group_name
  depends_on          = [module.terraform_azurerm_avm_res_compute_virtualmachinescaleset]
}

output "private_ip_addresses_app2" {
  value = flatten([for instance in data.azurerm_virtual_machine_scale_set.private_ip_address_app2.instances : instance.private_ip_address])
}



module "loadbalancer-lb2" {
  source              = "Azure/avm-res-network-loadbalancer/azurerm"
  version             = "0.2.2"
  name                = "app2-internal-lb"
  location            = local.location
  resource_group_name = local.resource_group_name
  #sku                 = "Basic"

  # Virtual Network and Subnet for Internal LoadBalancer
  # frontend_vnet_resource_id   = azurerm_virtual_network.example.id
  frontend_subnet_resource_id = module.subnet["lb2tier"].resource_id

  # Frontend IP Configuration
  frontend_ip_configurations = {
    frontend_configuration_1 = {
      name                                   = "myFrontend"
      frontend_private_ip_subnet_resource_id = module.subnet["lb2tier"].resource_id
      # zones = ["1", "2", "3"] # Zone-redundant
      #zones = ["None"] # Non-zonal
    }
  }
  # Backend Address Pool
  backend_address_pools = {
    pool1 = {
      name            = "myBackendPool"
      loadbalancer_id = module.loadbalancer-lb2.azurerm_lb.id
    }
  }

  backend_address_pool_addresses = {
    address1 = {
      name                             = "myBackendPool1" # must be unique if multiple addresses are used
      backend_address_pool_object_name = "pool1"
      ip_address                       = data.azurerm_virtual_machine_scale_set.private_ip_address_app2.instances[0].private_ip_address
      virtual_network_resource_id      = module.virtualnetwork["vnet"].resource_id
    }
    address2 = {
      name                             = "myBackendPool2" # must be unique if multiple addresses are used
      backend_address_pool_object_name = "pool1"
      ip_address                       = data.azurerm_virtual_machine_scale_set.private_ip_address_app2.instances[1].private_ip_address
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
