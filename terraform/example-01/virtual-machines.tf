locals {
  vm-prefixes = [
    for nic in azurerm_network_interface.private-nics : trimsuffix(nic.name, "-nic")
  ]
}

resource "azurerm_windows_virtual_machine" "regions-vms" {
  count                 = length(azurerm_network_interface.private-nics)
  name                  = "${local.vm-prefixes[count.index]}-vm"
  location              = azurerm_network_interface.private-nics[count.index].location
  resource_group_name   = azurerm_network_interface.private-nics[count.index].resource_group_name
  network_interface_ids = [azurerm_network_interface.private-nics[count.index].id]
  size                  = "Standard_D2s_v3"
  computer_name         = local.vm-prefixes[count.index]
  admin_username        = "resources_user"
  admin_password        = "Ys^S+8pSA#39w7y$"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "${local.vm-prefixes[count.index]}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
