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
      source = "hashicorp/azurerm"
      version = "~> 4.49.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kubernetes_context
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
    config_context = var.kubernetes_context
  }
}

provider "azurerm" {
  features {}
  # subscription_id = "a24b131f-bd0b-42e8-872a-bded9b91ab74"
  # tenant_id       = "e413b834-8be8-4822-a370-be619545cb49"
  subscription_id = var.zz_azure_subscription_id
  tenant_id       = var.zz_azure_entra_tenant_id
}
