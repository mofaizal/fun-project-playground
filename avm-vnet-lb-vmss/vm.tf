

#Network interface card
resource "azurerm_network_interface" "nic" {
  for_each = local.vms

  name                = each.value.nic_name
  resource_group_name = local.resource_group_name
  location            = local.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.subnet["testvmtier"].resource_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_virtual_machine" "vm" {

  for_each = local.vms

  name                  = each.value.vm_name
  resource_group_name   = local.resource_group_name
  location              = local.location
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  vm_size               = each.value.vm_size


  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-DataCenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myOsDisk-${each.key}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = each.value.host_name
    admin_username = each.value.admin_username
    admin_password = each.value.admin_password
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  storage_data_disk {
    name              = each.value.disk_name
    lun               = 0
    caching           = "ReadWrite"
    create_option     = "Empty"
    disk_size_gb      = each.value.data_disk_size_gb
    managed_disk_type = "Standard_LRS"
  }

}
