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

resource "azurerm_network_security_group" "nsg_aks" {
  name                = "aks-subnet-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-Inbound-NodeJS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_aks.id
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






