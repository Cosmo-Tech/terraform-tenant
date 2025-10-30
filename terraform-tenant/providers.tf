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
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.49.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.5.0"
    }
  }

  required_version = "~> 1.13.0"

  backend "azurerm" {
    storage_account_name             = "cosmotechstates" 
    container_name                   = "cosmotechstates"
    resource_group_name = "cosmotechstates"
    # key="tfstate-${var.tenant}"
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
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_entra_tenant_id
}


provider "aws" {
  region = var.aws_region
}


# provider "keycloak" {
#   client_id           = "user"
#   client_secret       = var.TF_VAR_keycloak_password_master
#   realm               = "master"
#   base_url            = "https://${var.cluster_domain}/keycloak/"
# }