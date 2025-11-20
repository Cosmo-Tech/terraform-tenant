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
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "~> 4.49.0"
    # }
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 6.18.0"
    # }
  }

  required_version = "~> 1.13.0"

  # Backend block is dynamically generated from _run-terraform.sh script

  # backend "azurerm" {
  #   storage_account_name = "cosmotechstates"
  #   container_name       = "cosmotechstates"
  #   resource_group_name  = "cosmotechstates"
  # }

  # backend "s3" {
  #   bucket = "cosmotech-states"
  #   region = "eu-west-3"
  #   key = "tfstate-eks-${var.cluster_stage}-${var.cluster_name}"
  # }
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



# data "azurerm_subscription" "azure" {}
# provider "azurerm" {
#   features {}
#   subscription_id = data.azurerm_subscription.azure.subscription_id
#   tenant_id       = data.azurerm_subscription.azure.tenant_id

#   # count = var.cloud_provider == "azure" ? 1 : 0
# }


# provider "aws" {
#   region = var.aws_region
# }

