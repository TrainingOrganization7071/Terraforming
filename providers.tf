# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
    
    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}






