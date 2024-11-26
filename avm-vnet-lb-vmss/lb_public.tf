resource "azurerm_public_ip" "example" {
  name                = "test"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  # domain_name_label   = azurerm_resource_group.example.name

  tags = {
    environment = "staging"
  }
}


module "loadbalancer_public" {
  source              = "Azure/avm-res-network-loadbalancer/azurerm"
  version             = "0.2.2"
  name                = "app1-public-lb"
  location            = local.location
  resource_group_name = local.resource_group_name

  # Virtual Network and Subnet for Internal LoadBalancer
  # frontend_vnet_resource_id   = azurerm_virtual_network.example.id
  frontend_subnet_resource_id = module.subnet["lbtier"].resource_id

  # Frontend IP Configuration
  frontend_ip_configurations = {
    frontend_configuration_1 = {
      name                 = "PublicIPAddress"
      public_ip_address_id = azurerm_public_ip.example.id
      # zones = ["1", "2", "3"] # Zone-redundant
      # zones = ["None"] # Non-zonal
    }
  }
  # Backend Address Pool
  backend_address_pools = {
    pool1 = {
      name = "myBackendPool"
      # loadbalancer_id = module.loadbalancer.azurerm_lb.id
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

    address3 = {
      name                             = "myBackendPool1" # must be unique if multiple addresses are used
      backend_address_pool_object_name = "pool1"
      ip_address                       = data.azurerm_virtual_machine_scale_set.private_ip_address_app2.instances[0].private_ip_address
      virtual_network_resource_id      = module.virtualnetwork["vnet"].resource_id
    }
    address4 = {
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
      frontend_ip_configuration_name = "PublicIPAddress"

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
