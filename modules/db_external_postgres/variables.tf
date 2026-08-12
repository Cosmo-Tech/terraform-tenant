variable "tenant" {
  description = "Full tenant namespace name (e.g. 'tenant-mytenant'), as output by the kube_namespace module."
  type        = string
}

variable "postgresql_admin_password" {
  description = "Cosmo Tech API admin password, as stored in the 'postgresql-cosmotechapi' Kubernetes Secret."
  type        = string
  sensitive   = true
}

variable "postgresql_writer_password" {
  description = "Cosmo Tech API writer password, as stored in the 'postgresql-cosmotechapi' Kubernetes Secret."
  type        = string
  sensitive   = true
}

variable "postgresql_reader_password" {
  description = "Cosmo Tech API reader password, as stored in the 'postgresql-cosmotechapi' Kubernetes Secret."
  type        = string
  sensitive   = true
}


variable "database_name" {
  description = "Name of the database to create for the tenant on the external PostgreSQL server."
  type        = string
}

variable "external_postgres_host" {
  description = "Hostname (FQDN) of the external PostgreSQL Flexible Server."
  type        = string
}

variable "external_postgres_port" {
  description = "Port of the external PostgreSQL server."
  type        = number
  default     = 5432
}
