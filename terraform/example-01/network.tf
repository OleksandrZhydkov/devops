locals {
  count-of-nics-per-vnet = var.count-of-vms-per-subnet
  nic-names = [
    for item in setproduct(azurerm_virtual_network.regions-vnets, range(local.count-of-nics-per-vnet)) : "${item[0].location}-${format("%02s", item[1])}-nic"
  ]
  nic-configs = [
    for item in range(local.count-of-nics-per-vnet * length(azurerm_virtual_network.regions-vnets)) : {
      name                = local.nic-names[item]
      location            = azurerm_virtual_network.regions-vnets[floor(item / local.count-of-nics-per-vnet)].location
      resource-group-name = azurerm_virtual_network.regions-vnets[floor(item / local.count-of-nics-per-vnet)].resource_group_name
      subnet-id           = azurerm_subnet.regions-subnets[floor(item / local.count-of-nics-per-vnet)].id
    }
  ]
}

resource "azurerm_virtual_network" "regions-vnets" {
  count               = length(azurerm_resource_group.regions-rgs)
  name                = "${azurerm_resource_group.regions-rgs[count.index].location}-vnet"
  location            = azurerm_resource_group.regions-rgs[count.index].location
  resource_group_name = azurerm_resource_group.regions-rgs[count.index].name
  address_space       = var.vnet-address-space
}

resource "azurerm_subnet" "regions-subnets" {
  count                = length(azurerm_virtual_network.regions-vnets)
  name                 = "${azurerm_virtual_network.regions-vnets[count.index].location}-subnet"
  resource_group_name  = azurerm_virtual_network.regions-vnets[count.index].resource_group_name
  virtual_network_name = azurerm_virtual_network.regions-vnets[count.index].name
  address_prefixes     = var.subnet-address-prefixes
}

resource "azurerm_network_interface" "private-nics" {
  count               = length(local.nic-configs)
  name                = local.nic-configs[count.index].name
  location            = local.nic-configs[count.index].location
  resource_group_name = local.nic-configs[count.index].resource-group-name

  ip_configuration {
    name                          = "private-ip-config"
    subnet_id                     = local.nic-configs[count.index].subnet-id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "regions-public-ips" {
  count               = length(azurerm_resource_group.regions-rgs)
  name                = "${azurerm_resource_group.regions-rgs[count.index].location}-public-ip"
  location            = azurerm_resource_group.regions-rgs[count.index].location
  resource_group_name = azurerm_resource_group.regions-rgs[count.index].name
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = trimsuffix(var.dns-zone, ".com")
}

# resource "azurerm_dns_zone" "regions-dns-zone" {
#   count               = length(azurerm_public_ip.regions-public-ips)
#   name                = var.dns-zone
#   resource_group_name = azurerm_public_ip.regions-public-ips[count.index].resource_group_name
# }

# output "server-names" {
#   value = [
#     for zone in azurerm_dns_zone.regions-dns-zone : zone.name_servers
#   ]
# }

# resource "azurerm_dns_a_record" "load-balancer-records" {
#   count               = length(azurerm_public_ip.regions-public-ips)
#   name                = azurerm_public_ip.regions-public-ips[count.index].location
#   zone_name           = var.dns-zone
#   resource_group_name = azurerm_public_ip.regions-public-ips[count.index].resource_group_name
#   ttl                 = 300
#   records             = [azurerm_public_ip.regions-public-ips[count.index].ip_address]
# }
