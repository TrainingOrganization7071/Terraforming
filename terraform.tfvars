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
network_plugin = "azure"
load_balancer_sku = "standard"
aks_service_cidr = "10.3.0.0/16"
aks_dns_service_ip = "10.3.0.10"

# API Management Variables

apim_subnet_name = "apim-subnet"
apim_subnet_cidr = "10.1.1.0/24"

apim_name = "apim-communication"
publisher_email = "test@contoso.com"
publisher_name = "publisher01"
sku = "Developer"
sku_count = 1

apim_api_name = "api-com"

# Linux Web App Variables

web_app_name = "webapp-frontend"
os_type = "Linux"
sku_value = "S1"
worker_count = 1




