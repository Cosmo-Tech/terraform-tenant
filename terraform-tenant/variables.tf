locals {
  main_name = "tenant-${var.tenant_name}"
}

variable "kubernetes_context" {
  description = "Kubernetes context (= the cluster) where to perform installation"
  type        = string
}

variable "tenant_name" {
  description = "Cosmo Tech tenant name"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider name where the deployment takes place"
  type = string

  validation {
    condition     = contains(["kob", "azure", "aws", "gcp"], var.cluster_stage)
    error_message = "Valid values for 'cloud_provider' are: \n- kob\n- azure\n- aws\n- gcp"
  }
}



variable "zz_azure_subscription_id" {
  description = "[temporary] Azure subscription ID"
  type = string
}

variable "zz_azure_entra_tenant_id" {
  description = "[temporary] Azure Entra tenant ID"
  type = string
}

variable "zz_azure_aks_rg_name" {
  description = "[temporary] Azure resource group of the AKS cluster (name)"
  type = string
}

variable "zz_azure_aks_rg_region" {
  description = "[temporary] Azure of resource group of the AKS cluster (region)"
  type = string
}

