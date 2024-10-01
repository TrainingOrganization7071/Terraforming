resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [ azurerm_subnet.aks_subnet ]
  name                = var.aks_cluster_name
  kubernetes_version = var.kubernetes_version
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  private_cluster_enabled = false

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin    = var.network_plugin
    network_plugin_mode = "overlay"
    load_balancer_sku = var.load_balancer_sku
    service_cidr      = var.aks_service_cidr  # Change this to a non-overlapping CIDR range
    dns_service_ip    = var.aks_dns_service_ip    # Adjust the DNS service IP accordingly
    #docker_bridge_cidr = "172.17.0.1/16" # Use a typical non-conflicting range for the Docker bridge net
  }

  identity {
    type = "SystemAssigned"
  }

  web_app_routing {
    dns_zone_ids = null
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

resource "terraform_data" "questdb" {
  depends_on = [ terraform_data.localexec ]
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/deploy-questdb.yml"
  }
}








