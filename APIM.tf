resource "azurerm_public_ip" "pip-apim" {
  name                = "pip-apim"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  domain_name_label   = "apim-extern-7071"
}

resource "random_string" "randomapim" {
  length           = 16
  special          = false
  lower   = true
  numeric = false
  upper   = false
}

resource "azurerm_api_management" "apim" {
  depends_on = [ azurerm_linux_web_app.front_web_app ]
  name                = "${var.apim_name}-${random_string.randomapim.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "${var.sku}_${var.sku_count}"  # Use Developer tier for cost savings
  virtual_network_type          = "External" # None, External, Internal

  # VNET integration for API Management (Internal Mode)
  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim_subnet.id
  }
  
  identity {
    type = "SystemAssigned"
  }

  # Set API Management to only be accessible via VNET
    # Initially enable public network access
  public_network_access_enabled = true # false applies only when using private endpoint as the exclusive access method
}

resource "azurerm_api_management_api" "api" {
  name                = var.apim_api_name
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Example API"
  path                = "example"
  protocols           = ["https", "http"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
}










