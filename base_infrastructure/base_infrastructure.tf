  # Resource Group For Infrastructure
  resource "azurerm_resource_group" "gareth_resource_group" {
    name     = "resource_group"
    location = "uksouth"
  }

  