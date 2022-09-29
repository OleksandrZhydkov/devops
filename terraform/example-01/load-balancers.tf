resource "azurerm_lb" "regions-load-balancers" {
  count               = length(azurerm_public_ip.regions-public-ips)
  name                = "${azurerm_public_ip.regions-public-ips[count.index].location}-lb"
  location            = azurerm_public_ip.regions-public-ips[count.index].location
  resource_group_name = azurerm_public_ip.regions-public-ips[count.index].resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${azurerm_public_ip.regions-public-ips[count.index].location}-ip-config"
    public_ip_address_id = azurerm_public_ip.regions-public-ips[count.index].id
  }
}

resource "azurerm_lb_backend_address_pool" "regions-backend-address-pools" {
  count           = length(azurerm_lb.regions-load-balancers)
  loadbalancer_id = azurerm_lb.regions-load-balancers[count.index].id
  name            = "${azurerm_lb.regions-load-balancers[count.index].location}-pool"
}

resource "azurerm_lb_backend_address_pool_address" "regions-pool-addresses" {
  count                   = length(azurerm_network_interface.private-nics)
  name                    = "${azurerm_windows_virtual_machine.regions-vms[count.index].name}-pool-address"
  backend_address_pool_id = azurerm_lb_backend_address_pool.regions-backend-address-pools[floor(count.index / var.count-of-vms-per-subnet)].id
  virtual_network_id      = azurerm_virtual_network.regions-vnets[floor(count.index / var.count-of-vms-per-subnet)].id
  ip_address              = azurerm_network_interface.private-nics[count.index].private_ip_address
}

resource "azurerm_lb_probe" "regions-load-balancers-probes" {
  count           = length(azurerm_lb.regions-load-balancers)
  loadbalancer_id = azurerm_lb.regions-load-balancers[count.index].id
  name            = "${azurerm_lb.regions-load-balancers[count.index].name}-probe"
  port            = 80
}

resource "azurerm_lb_rule" "regions-load-balancers-rules" {
  count                          = length(azurerm_lb.regions-load-balancers)
  loadbalancer_id                = azurerm_lb.regions-load-balancers[count.index].id
  name                           = "${azurerm_lb.regions-load-balancers[count.index].name}-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${azurerm_lb.regions-load-balancers[count.index].location}-ip-config"
}
