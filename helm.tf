/*
data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.aks_back.name
  resource_group_name = azurerm_resource_group.rg.name
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
  }
}

resource "helm_release" "nginx_ingress" {
  name = "nginx-ingress-controller"
  namespace = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}

resource "helm_release" "questdb_release" {
  name = "quest-db"
  namespace = "default"
  repository = "https://helm.questdb.io/"
  chart      = "questdb"
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
*/







