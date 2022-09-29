# resource "azurerm_virtual_machine_extension" "vm-extensions" {
#   count                = length(azurerm_windows_virtual_machine.regions-vms)
#   name                 = "${azurerm_windows_virtual_machine.regions-vms[count.index].name}-extension"
#   virtual_machine_id   = azurerm_windows_virtual_machine.regions-vms[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"

#   settings = <<SETTINGS
#     {
#         "fileUris": ["https://${azurerm_storage_container.containers[floor(count.index / var.count-of-vms-per-subnet)].storage_account_name}.blob.core.windows.net/${azurerm_storage_container.containers[floor(count.index / var.count-of-vms-per-subnet)].name}/${var.deploy-file-name}"],
#           "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file ${var.deploy-file-name}"     
#     }
# SETTINGS
# }
