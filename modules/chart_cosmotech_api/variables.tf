variable "tenant" {
  type = string
}

variable "release" {
  type = string
}

variable "postgresql_host" {
  type = string
}

variable "postgresql_port" {
  type = string
}

variable "s3_host" {
  type = string
}

variable "s3_port" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_secret" {
  type = string
}

variable "s3_secret_key_username" {
  type = string
}

variable "s3_secret_key_password" {
  type = string
}

variable "postgresql_database" {
  type = string
}

variable "postgresql_admin_username" {
  type = string
}

variable "postgresql_admin_password" {
  type = string
}

variable "postgresql_writer_username" {
  type = string
}

variable "postgresql_writer_password" {
  type = string
}

variable "postgresql_reader_username" {
  type = string
}

variable "postgresql_reader_password" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "keycloak_client_id" {
  type = string
}

variable "keycloak_client_secret" {
  type = string
}

variable "cosmotech_api_connect_timeout" {
  type = string
  default = "30s"
}

variable "cosmotech_api_query_timeout" {
  type = string
  default = "60s"
}

variable "cosmotech_api_buffer_size" {
  type = string
  default = "16K"
}

variable "cosmotech_api_max_file_size" {
  type = string
  default = "50m"
}

