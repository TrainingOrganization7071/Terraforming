rg_name = "minimal_infra_auth"
rg_location = "UAE North" // All The Arch Deploued on : UAE North

aks_vnet_name  = "aks-vnet"
aks_vnet_address_space = "10.1.0.0/16"

aks_subnet_name = "aks_subnet"
aks_subnet_cidr = "10.1.2.0/24" 

# AKS Variables

aks_cluster_name = "aks_back"
kubernetes_version = "1.29"
dns_prefix = "exampleaks1"
node_count = 1
vm_size = "Standard_DS2_v2"
network_plugin = "kubenet"
load_balancer_sku = "standard"
aks_service_cidr = "10.3.0.0/16"
aks_dns_service_ip = "10.3.0.10"