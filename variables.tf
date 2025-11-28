locals {
  main_name = "tenant-${var.tenant}"
}

variable "cluster_name" {
  description = "Kubernetes cluster where to perform installation (must be one of the clusters (=/= context) in your kubectl config)"
  type        = string
}

variable "tenant" {
  description = "Cosmo Tech tenant name"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider name where the deployment takes place"
  type        = string

  validation {
    condition     = contains(["kob", "azure", "aws", "gcp"], var.cloud_provider)
    error_message = "Valid values for 'cloud_provider' are: \n- kob\n- azure\n- aws\n- gcp"
  }
}

variable "cluster_domain" {
  description = "Cluster domain"
  type        = string
}

variable "cluster_region" {
  description = "Region where to store tenant objects (like disks for example)"
  type        = string
}
