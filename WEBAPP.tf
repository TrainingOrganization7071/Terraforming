resource "random_string" "random" {
  length           = 16
  special          = false
  lower   = true
  numeric = false
  upper   = false
}

resource "azurerm_service_plan" "service_plan_web_app" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  name                = "${var.web_app_name}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  per_site_scaling_enabled = false
  os_type             = var.os_type
  sku_name            = var.sku_value  
  worker_count = var.worker_count
}

resource "azurerm_linux_web_app" "front_web_app" {
  depends_on = [ azurerm_service_plan.service_plan_web_app ]
  name                = "${var.web_app_name}-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.service_plan_web_app.id
  public_network_access_enabled = true
  
  site_config {
    # Runtime stack for Node.js
    #linux_fx_version = "NODE|14"
    http2_enabled = true

    # Disable always_on to save costs
    always_on = false

    # VNET Integration with the App Service Subneta
    #vnet_route_all_enabled = true
  }
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITE_NODE_DEFAULT_VERSION        = "14.17.0"
  }
}





