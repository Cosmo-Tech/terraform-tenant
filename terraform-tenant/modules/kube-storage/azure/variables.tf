variable "tenant" {
  type = string
}

variable "resource" {
  description = "Name of the resource that needs the persistent storage"
  type        = string
}

variable "size" {
  description = "Size of the disk/pv/pvc"
  type        = number
}

variable "storage_class_name" {
  description = "Storage class for disk/pv/pvc"
  type = string
}



variable "zz_azure_subscription_id" {
  description = "[temporary] Azure subscription ID"
  type        = string
}

variable "zz_azure_entra_tenant_id" {
  description = "[temporary] Azure Entra tenant ID"
  type        = string
}

variable "zz_azure_aks_rg_name" {
  description = "[temporary] Azure resource group of the AKS cluster (name)"
  type        = string
}

variable "zz_azure_aks_rg_region" {
  description = "[temporary] Azure of resource group of the AKS cluster (region)"
  type        = string
}
