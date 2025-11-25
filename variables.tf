locals {
  main_name = "tenant-${var.tenant}"
}

variable "cluster_name" {
  description = "Kubernetes cluster where to perform installation"
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
  description = "[temporary] Cluster domain"
  type        = string
}

# variable "azure_subscription_id" {
#   description = "[temporary] Azure subscription ID"
#   type        = string
# }

# variable "azure_entra_tenant_id" {
#   description = "[temporary] Azure Entra tenant ID"
#   type        = string
# }

# variable "azure_resource_group" {
#   type = string
# }

# variable "azure_region" {
#   description = "Region where to store tenant objects (like disks for example)"
#   type        = string
# }

# variable "aws_region" {
#   description = "Region where to store tenant objects (like disks for example)"
#   type        = string
# }

variable "region" {
  description = "Region where to store tenant objects (like disks for example)"
  type        = string
}

# variable "keycloak_admin_username" {
#   type = string
# }

# variable "keycloak_admin_password" {
#   type = string
# }
