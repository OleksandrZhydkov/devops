# resource "azurerm_storage_account" "appstores" {
#   count                    = length(azurerm_resource_group.regions-rgs)
#   name                     = "${azurerm_resource_group.regions-rgs[count.index].location}appstore"
#   resource_group_name      = azurerm_resource_group.regions-rgs[count.index].name
#   location                 = azurerm_resource_group.regions-rgs[count.index].location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_storage_container" "containers" {
#   count                 = length(azurerm_storage_account.appstores)
#   name                  = "container"
#   storage_account_name  = azurerm_storage_account.appstores[count.index].name
#   container_access_type = "blob"
# }

# resource "azurerm_storage_blob" "iis-deploy-blobs" {
#   count                  = length(azurerm_storage_container.containers)
#   name                   = var.deploy-file-name
#   storage_account_name   = azurerm_storage_container.containers[count.index].storage_account_name
#   storage_container_name = azurerm_storage_container.containers[count.index].name
#   type                   = "Block"
#   source                 = var.deploy-file-name
# }
