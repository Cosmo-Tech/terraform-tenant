variable "tenant" {
  type = string
}

variable "image_registry" {
  type = string
}

variable "image_registry_auth_secret" {
  type = string
}

variable "chart_repository" {
  type = string
}

variable "chart_name" {
  type = string
}

variable "chart_tag" {
  type = string
}

variable "chart_release" {
  type = string
}

variable "size" {
  type = string
}

variable "pvc" {
  type = string
}

variable "pvc_storage_class" {
  type = string
}

variable "postgresql_image_repository" {
  type = string
}

variable "postgresql_image_tag" {
  type = string
}

variable "use_external_postgres" {
  description = "If true, the Cosmo Tech API database is provisioned on an external PostgreSQL server, so the in-cluster init Job for it is skipped (roles/db/schema are created by the 'db_external_postgres' module instead). The 'postgresql-cosmotechapi' Secret is still created so credentials can be shared with the external provisioning module and the cosmotech-api Helm release."
  type        = bool
  default     = false
}
