provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "regions-rgs" {
  count    = length(var.locations)
  name     = "${var.locations[count.index]}-rg"
  location = var.locations[count.index]
}
