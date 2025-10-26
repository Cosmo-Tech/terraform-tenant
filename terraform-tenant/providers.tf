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
    # template = {
    #   source  = "hashicorp/template"
    #   version = "2.2.0"
    # }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.49.0"
    }
    # postgresql = {
    #   source = "cyrilgdn/postgresql"
    #   version = "~> 1.26.0"
    # }
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

provider "azurerm" {
  features {}
  subscription_id = var.zz_azure_subscription_id
  tenant_id       = var.zz_azure_entra_tenant_id
}


# provider "postgresql" {}