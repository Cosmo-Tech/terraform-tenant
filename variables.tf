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

variable "domain_zone" {
  description = "Cluster domain zone"
  type        = string
}

variable "cluster_region" {
  description = "Region where to store tenant objects (like disks for example)"
  type        = string
  default     = null
}

variable "tenant_type" {
  description = "Tenant type to deploy (will automatically select the rights modules to deploy)"
  type        = string

  validation {
    condition     = contains(["running", "modeling", "asset", "asset_portfolio"], var.tenant_type)
    error_message = "Valid values for 'tenant_type' are: \n- running\n- modeling\n- asset\n- asset_portfolio"
  }
}




# External PostgreSQL (Azure Flexible Server) support
variable "use_external_postgres" {
  description = "If true, the tenant Cosmo Tech API database is provisioned on an external PostgreSQL server (e.g. Azure PostgreSQL Flexible Server, provisioned by terraform-extra) instead of the in-cluster PostgreSQL chart."
  type        = bool
  default     = false
}

variable "external_postgres_host" {
  description = "Hostname (FQDN) of the external PostgreSQL Flexible Server. Required when 'use_external_postgres' is true."
  type        = string
  default     = null
}

variable "external_postgres_port" {
  description = "Port of the external PostgreSQL server."
  type        = number
  default     = 5432
}

variable "external_postgres_admin_username" {
  description = "Server-level admin (superuser) username used by Terraform to connect to the external PostgreSQL server and provision tenant roles/databases. Required when 'use_external_postgres' is true."
  type        = string
}

variable "external_postgres_admin_password" {
  description = "Server-level admin (superuser) password used by Terraform to connect to the external PostgreSQL server. Required when 'use_external_postgres' is true."
  type        = string
  sensitive   = true
}

variable "external_postgres_sslmode" {
  description = "SSL mode used to connect to the external PostgreSQL server."
  type        = string
  default     = "require"
}

variable "external_postgres_superuser" {
  description = "Whether the admin connection used by the postgresql provider has PostgreSQL SUPERUSER privileges. Azure PostgreSQL Flexible Server admin accounts are NOT superusers, so this should be 'false' on Azure."
  type        = bool
  default     = false
}
