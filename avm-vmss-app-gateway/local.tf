locals {

  resource_group_name = "rg-avm-vmss-app-gateway"
  location            = "southeastasia"

  virtual_network = {
    vnet = {
      name          = "workload-c-vnet"
      address_space = "10.201.0.0/16"
    }
  }

  subnet = {
    "gatewaytier" = {
      name             = "appgateway-subnet"
      address_prefixes = "10.201.1.0/24"
      nsg_name         = "appgateway-subnet-nsg"
    },
    "webtier" = {
      name             = "websubnet"
      address_prefixes = "10.201.2.0/24"
      nsg_name         = "websubnet-nsg"
    },
    "apptier" = {
      name             = "appsubnet"
      address_prefixes = "10.201.4.0/24"
      nsg_name         = "appsubnet-nsg"
    },
    "dbtier" = {
      name             = "dbsubnet"
      address_prefixes = "10.201.5.0/24"
      nsg_name         = "dbsubnet-nsg"
    },
  }

  nsg_rules = {
    "rule01" = {
      name                       = "rules"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["80", "443"]
      direction                  = "Inbound"
      priority                   = 200
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    },
    "gateway" = {
      name                       = "gateway-rules"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["65200-65535"]
      direction                  = "Inbound"
      priority                   = 300
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }

  tags = {
    scenario = "VMSS Autoscale Linux AVM Sample"
  }

  webvm_custom_data = <<CUSTOM_DATA
#!/bin/sh
#!/bin/sh
#sudo yum update -y
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd  
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo chmod -R 777 /var/www/html 
sudo echo "Welcome to Azure Verified Modules - Application Gateway Root - VM Hostname: $(hostname)" > /var/www/html/index.html
sudo mkdir /var/www/html/app1
sudo echo "Welcome to Azure Verified Modules - Application Gateway Host App1 - VM Hostname: $(hostname)" > /var/www/html/app1/hostname.html
sudo echo "Welcome to Azure Verified Modules - Application Gateway - App1 Status Page" > /var/www/html/app1/status.html
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(132, 204, 22);"> <h1>Welcome to Azure Verified Modules - Application Gateway APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
sudo mkdir /var/www/html/app2
sudo echo "Welcome to Azure Verified Modules - Application Gateway Host App1 - VM Hostname: $(hostname)" > /var/www/html/app2/hostname.html
sudo echo "Welcome to Azure Verified Modules - Application Gateway - App1 Status Page" > /var/www/html/app2/status.html
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(22, 134, 204);"> <h1>Welcome to Azure Verified Modules - Application Gateway APP-2 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app2/index.html

CUSTOM_DATA

}
