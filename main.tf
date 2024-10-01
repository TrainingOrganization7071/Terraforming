resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

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

# Assign the Network Contributor role to the AKS system-assigned identity
resource "azurerm_role_assignment" "aks_network_contributor" {
  principal_id   = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope          = azurerm_virtual_network.vnet_aks.id
}

#az aks get-credentials --resource-group minimal_infra_auth --name aks_back

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

# DNS Zone 

resource "random_string" "azurerm_dns_zone_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_dns_zone" "dns-public" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  #name                = "apinostrada.com"
  name                =(
    var.dns_zone_name != null ?
    var.dns_zone_name :
    "www.${random_string.azurerm_dns_zone_name.result}.azurequickstart.org"
  )
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "record" {
  name                = "www"
  resource_group_name = azurerm_resource_group.rg.name
  zone_name           = azurerm_dns_zone.dns-public.name
  ttl                 = var.dns_ttl
  records             = var.dns_records
}


# Web APP Service

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
    #vnet_route_all_enabled = true
  }
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITE_NODE_DEFAULT_VERSION        = "14.17.0"
  }
}


# Subnet for APIM

resource "azurerm_subnet" "apim_subnet" {
  name                 = var.apim_subnet_name
  resource_group_name  = var.rg_name
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

resource "random_string" "randomapim" {
  length           = 16
  special          = false
  lower   = true
  numeric = false
  upper   = false
}

resource "azurerm_api_management" "apim" {
  depends_on = [ azurerm_kubernetes_cluster.aks ]
  name                = "${var.apim_name}-${random_string.randomapim.result}"
  location            = var.rg_location
  resource_group_name = var.rg_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "${var.sku}_${var.sku_count}"  # Use Developer tier for cost savings

  # VNET integration for API Management (Internal Mode)
  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim_subnet.id
  }
  
  identity {
    type = "SystemAssigned"
  }

  # Set API Management to only be accessible via VNET
    # Initially enable public network access
  public_network_access_enabled = true
}

























