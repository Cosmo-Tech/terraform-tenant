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
