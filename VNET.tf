resource "azurerm_virtual_network" "vnet_aks" {
  name                = var.aks_vnet_name
  address_space       = [ var.aks_vnet_address_space ]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name
  address_prefixes     = [ var.aks_subnet_cidr ]
}

# Subnet for APIM

resource "azurerm_subnet" "apim_subnet" {
  name                 = var.apim_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_aks.name
  address_prefixes     = [var.apim_subnet_cidr]

  # Required for API Management to be in internal mode
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.ApiManagement/service"
    }
  }
}






