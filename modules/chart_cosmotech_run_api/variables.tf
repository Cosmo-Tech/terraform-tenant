variable "tenant" {
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

variable "image_registry" {
  type = string
}

variable "image_registry_auth_secret" {
  type = string
}

variable "image_repository" {
  type = string
}

variable "image_tag" {
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

variable "keycloak_client_id" {
  type = string
}

variable "keycloak_client_secret" {
  type = string
}

variable "use_external_postgresql" {
  type = bool
}

variable "external_postgresql_host" {
  type = string
}

variable "external_postgresql_port" {
  type = string
}

variable "external_postgresql_username" {
  type = string
}

variable "external_postgresql_password" {
  type = string
}

variable "internal_postgresql_host" {
  type = string
}

variable "internal_postgresql_port" {
  type = string
}

variable "internal_postgresql_image_repository" {
  type = string
}

variable "internal_postgresql_image_tag" {
  type = string
}

variable "cluster_domain" {
  type = string
}