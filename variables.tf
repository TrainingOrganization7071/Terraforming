variable "rg_name" {
  type        = string
}

variable "rg_location" {
  type        = string
}

variable "aks_vnet_name" {
  type = string
}

variable "aks_vnet_address_space" {
  type = string
  description = "Vertual network address space"
}

variable "aks_subnet_name" {
  type = string
  description = "AKS subnet name"
}

variable "aks_subnet_cidr" {
  type = string
  description = "AKS subnet ip range"
}

variable "aks_cluster_name" {
  type = string
  description = "Azure K8S cluster name"
}

variable "kubernetes_version" {
  type = string
  description = "Azure K8S cluster version"
}

variable "dns_prefix" {
  type = string
  description = "Domain name prefix"
}

variable "node_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "network_plugin" {
  type = string
  description = "AKS network plugin"
}

variable "load_balancer_sku" {
  type = string
  description = "AKS Load_balancer_sku"
}

variable "aks_service_cidr" {
  type = string
  description = "Service CIDR"
}

variable "aks_dns_service_ip" {
  type = string
  description = "DNS Service IP"
}


variable "web_app_name" {
  type = string
  description = "Web App Service name / ReactJs"
}

variable "os_type" {
  type = string
  description = "OS type of the web app"
}

variable "sku_value" {
  type = string
  description = ""
}

variable "worker_count" {
  type = number
}
