resource "azurerm_traffic_manager_profile" "traffic-profile" {
  name                   = "traffic-profile"
  resource_group_name    = azurerm_resource_group.regions-rgs[0].name
  traffic_routing_method = "Performance"
  dns_config {
    relative_name = "traffic-profile"
    ttl           = 100
  }
  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "traffic-manager-endpoints" {
  count              = length(azurerm_public_ip.regions-public-ips)
  name               = "${azurerm_public_ip.regions-public-ips[count.index].name}-endpoint"
  profile_id         = azurerm_traffic_manager_profile.traffic-profile.id
  target_resource_id = azurerm_public_ip.regions-public-ips[count.index].id
}
