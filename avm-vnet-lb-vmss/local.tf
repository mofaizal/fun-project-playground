locals {

  resource_group_name = "rg-avm-workload"
  location            = "southeastasia"

  virtual_network = {
    vnet = {
      name          = "workload-vnet"
      address_space = "10.201.0.0/16"
    }
  }

  vms = {
    vm1 = {
      vm_name           = "app1VM1"
      nic_name          = "app1-vm-nic"
      host_name         = "app1-vm"
      disk_name         = "app1-data"
      vm_size           = "Standard_DS1_v2"
      admin_username    = "azureuser"
      admin_password    = "P@ssword123456"
      data_disk_size_gb = 10
      subnet            = "testing-vm-subnet"
    },
    vm2 = {
      vm_name           = "app2VM1"
      nic_name          = "app2-vm-nic"
      host_name         = "app2-vm"
      disk_name         = "app2-data"
      vm_size           = "Standard_DS1_v2"
      admin_username    = "azureuser"
      admin_password    = "P@ssword123456"
      data_disk_size_gb = 10
      subnet            = "testing-vm-subnet"
    }
  }
  subnet = {
    "testvmtier" = {
      name             = "testing-vm-subnet"
      address_prefixes = "10.201.1.0/24"
      nsg_name         = "testvm-nsg"
    },
    "lbtier" = {
      name             = "app1-lb-subnet"
      address_prefixes = "10.201.2.0/24"
      nsg_name         = "app1-lb-subnet-nsg"
    },
    "appgroup1tier" = {
      name             = "app1-group1-subnet"
      address_prefixes = "10.201.3.0/24"
      nsg_name         = "app1-group1-subnet-nsg"
    },
    "lb2tier" = {
      name             = "app2-lb-subnet"
      address_prefixes = "10.201.4.0/24"
      nsg_name         = "app2-lb-subnet-nsg"
    },
    "appgroup2tier" = {
      name             = "app2-group2-subnet"
      address_prefixes = "10.201.5.0/24"
      nsg_name         = "app2-group2-subnet-nsg"
    },
    "AzureBastionSubnet" = {
      name             = "AzureBastionSubnet"
      address_prefixes = "10.201.6.0/24"
      nsg_name         = "AzureBastionSubnet-nsg"
    }


  }

  nsg_rules = {
    "rule01" = {
      name                       = "AllowSpecificIP"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["80", "443"]
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    },
    "rule02" = {
      name                       = "DenyOtherTraffic"
      access                     = "Deny"
      destination_address_prefix = "*"
      destination_port_ranges    = ["80", "443"]
      direction                  = "Inbound"
      priority                   = 200
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }

  tags = {
    scenario = "VMSS Autoscale Linux AVM Sample"
  }

  #   webvm_custom_data = <<CUSTOM_DATA
  # #!/bin/sh
  # #!/bin/sh
  # #sudo yum update -y
  # sudo yum install -y httpd
  # sudo systemctl enable httpd
  # sudo systemctl start httpd  
  # sudo systemctl stop firewalld
  # sudo systemctl disable firewalld
  # sudo chmod -R 777 /var/www/html 
  # sudo echo "Welcome to Azure Verified Modules - Application Gateway Root - VM Hostname: $(hostname)" > /var/www/html/index.html
  # sudo mkdir /var/www/html/app1
  # sudo echo "Welcome to Azure Verified Modules - Application Gateway Host App1 - VM Hostname: $(hostname)" > /var/www/html/app1/hostname.html
  # sudo echo "Welcome to Azure Verified Modules - Application Gateway - App1 Status Page" > /var/www/html/app1/status.html
  # sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(132, 204, 22);"> <h1>Welcome to Azure Verified Modules - Application Gateway APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app1/index.html
  # sudo mkdir /var/www/html/app2
  # sudo echo "Welcome to Azure Verified Modules - Application Gateway Host App1 - VM Hostname: $(hostname)" > /var/www/html/app2/hostname.html
  # sudo echo "Welcome to Azure Verified Modules - Application Gateway - App1 Status Page" > /var/www/html/app2/status.html
  # sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(22, 134, 204);"> <h1>Welcome to Azure Verified Modules - Application Gateway APP-2 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app2/index.html

  # CUSTOM_DATA

  webvm_custom_data = <<CUSTOM_DATA
#!/bin/sh

# Update the system and install Apache HTTP server and PHP
sudo yum update -y
sudo yum install -y httpd php

# Enable and start Apache
sudo systemctl enable httpd
sudo systemctl start httpd  

# Disable and stop the firewall (optional, ensure this aligns with your security policies)
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Set permissions for the web root directory
sudo chmod -R 755 /var/www/html 

# Configure Apache to handle PHP files
sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf

# Restart Apache to apply changes
sudo systemctl restart httpd

# Create main root page with PHP to display client IP and hostname
cat <<EOF | sudo tee /var/www/html/index.php
<?php
echo "<h1>Welcome to Azure Verified Modules - Application Gateway Root</h1>";
echo "<p>VM Hostname: " . gethostname() . "</p>";
echo "<p>Client IP: " . \$_SERVER['REMOTE_ADDR'] . "</p>";
?>
EOF

# Set up App1 pages with PHP to display client IP and hostname
sudo mkdir -p /var/www/html/app1

cat <<EOF | sudo tee /var/www/html/app1/hostname.php
<?php
echo "<h1>Welcome to Azure Verified Modules - Application Gateway Host App1</h1>";
echo "<p>VM Hostname: " . gethostname() . "</p>";
echo "<p>Client IP: " . \$_SERVER['REMOTE_ADDR'] . "</p>";
?>
EOF

cat <<EOF | sudo tee /var/www/html/app1/status.php
<?php
echo "<h1>Welcome to Azure Verified Modules - Application Gateway - App1 Status Page</h1>";
echo "<p>Client IP: " . \$_SERVER['REMOTE_ADDR'] . "</p>";
?>
EOF

cat <<EOF | sudo tee /var/www/html/app1/index.php
<?php
echo '<!DOCTYPE html>
<html>
<body style="background-color:rgb(132, 204, 22);">
    <h1>Welcome to Azure Verified Modules - Application Gateway APP-1</h1>
    <p>Terraform Demo</p>
    <p>Application Version: V1</p>
    <p>Client IP: ' . \$_SERVER['REMOTE_ADDR'] . '</p>
</body>
</html>';
?>
EOF

# Set up App2 pages with PHP to display client IP and hostname
sudo mkdir -p /var/www/html/app2

cat <<EOF | sudo tee /var/www/html/app2/hostname.php
<?php
echo "<h1>Welcome to Azure Verified Modules - Application Gateway Host App2</h1>";
echo "<p>VM Hostname: " . gethostname() . "</p>";
echo "<p>Client IP: " . \$_SERVER['REMOTE_ADDR'] . "</p>";
?>
EOF

cat <<EOF | sudo tee /var/www/html/app2/status.php
<?php
echo "<h1>Welcome to Azure Verified Modules - Application Gateway - App2 Status Page</h1>";
echo "<p>Client IP: " . \$_SERVER['REMOTE_ADDR'] . "</p>";
?>
EOF

cat <<EOF | sudo tee /var/www/html/app2/index.php
<?php
echo '<!DOCTYPE html>
<html>
<body style="background-color:rgb(22, 134, 204);">
    <h1>Welcome to Azure Verified Modules - Application Gateway APP-2</h1>
    <p>Terraform Demo</p>
    <p>Application Version: V1</p>
    <p>Client IP: ' . \$_SERVER['REMOTE_ADDR'] . '</p>
</body>
</html>';
?>
EOF

# Set appropriate permissions for PHP files
sudo chmod -R 755 /var/www/html
CUSTOM_DATA


}
