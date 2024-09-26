resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

/*
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

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [ azurerm_subnet.aks_subnet ]
  name                = var.aks_cluster_name
  kubernetes_version = var.kubernetes_version
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = var.load_balancer_sku
    service_cidr      = var.aks_service_cidr  # Change this to a non-overlapping CIDR range
    dns_service_ip    = var.aks_dns_service_ip    # Adjust the DNS service IP accordingly
    #docker_bridge_cidr = "172.17.0.1/16" # Use a typical non-conflicting range for the Docker bridge net
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "test"
  }
}

resource "local_file" "kubeconfig" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw
  filename = "${path.module}/kube_config"
}

resource "terraform_data" "localexec" {
  depends_on = [ local_file.kubeconfig ]
  provisioner "local-exec" {
    command = "cat ${path.module}/kube_config > ~/.kube/config"
  }
}

*/




resource "random_string" "random" {
  length           = 16
  special          = false
  lower   = true
  numeric = false
  upper   = false
}

resource "azurerm_service_plan" "service_plan_web_app" {
  depends_on = [ azurerm_resource_group.rg ]
  name                = "${var.web_app_name}-plan"
  resource_group_name = var.rg_name
  location            = var.rg_location
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
    //vnet_route_all_enabled = true
  }
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITE_NODE_DEFAULT_VERSION        = "14.17.0"
  }
}







