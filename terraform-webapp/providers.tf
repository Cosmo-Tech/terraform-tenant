terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
  }

  required_version = "~> 1.13.0"

  backend "azurerm" {
    storage_account_name = "cosmotechstates"
    container_name       = "cosmotechstates"
    resource_group_name  = "cosmotechstates"
  }
}


provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kubernetes_context
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = var.kubernetes_context
  }
}
