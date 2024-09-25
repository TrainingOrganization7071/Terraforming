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









