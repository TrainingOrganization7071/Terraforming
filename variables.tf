variable "rg_name" {
  type        = string
}

variable "rg_location" {
  type        = string
}

variable "aks_vnet_name" {
  type = string
}

# AKS ------------------------

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


# API ---------------------

variable "apim_subnet_name" {
  type = string
  description = "Api management subnet name"
  //default = "apim-subnet"
}

variable "apim_subnet_cidr" {
  type = string
  description = "Api management subnet ip range"
  //default = "10.1.1.0/24"
}

variable "apim_name" {
  type = string
  default = "apim-communication"
}

variable "apim_api_name" {
  type = string
  //default = "api-com"
}

variable "publisher_email" {
  //default     = "test@contoso.com"
  description = "The email address of the owner of the service"
  type        = string
  validation {
    condition     = length(var.publisher_email) > 0
    error_message = "The publisher_email must contain at least one character."
  }
}

variable "publisher_name" {
  //default     = "publisher"
  description = "The name of the owner of the service"
  type        = string
  validation {
    condition     = length(var.publisher_name) > 0
    error_message = "The publisher_name must contain at least one character."
  }
}

variable "sku" {
  description = "The pricing tier of this API Management service"
  //default     = "Developer"
  type        = string
  validation {
    condition     = contains(["Developer", "Standard", "Premium"], var.sku)
    error_message = "The sku must be one of the following: Developer, Standard, Premium."
  }
}

variable "sku_count" {
  description = "The instance size of this API Management service."
  //default     = 1
  type        = number
  validation {
    condition     = contains([1, 2], var.sku_count)
    error_message = "The sku_count must be one of the following: 1, 2."
  }
}


#Web App -----------------------

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
