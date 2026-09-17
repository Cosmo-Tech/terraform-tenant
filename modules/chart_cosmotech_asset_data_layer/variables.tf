variable "namespace" {
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

variable "registry" {
  type = string
}

variable "registry_auth_secret" {
  type = string
}

variable "cosmotech_asset_data_layer_image_name" {
  type = string
}

variable "cosmotech_asset_data_layer_image_tag" {
  type = string
}

variable "use_external_postgresql" {
  type = string
}

variable "internal_postgresql_image_name" {
  type = string
}

variable "internal_postgresql_image_tag" {
  type = string
}

variable "database_host" {
  type = string
}

variable "database_port" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_username" {
  type = string
}

variable "database_password" {
  type = string
}

variable "database_admin_username" {
  type = string
}

variable "database_admin_password" {
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

variable "persistence_size" {
  type = string
}

variable "persistence_pvc" {
  type = string
}

variable "pvc_storage_class" {
  type = string
}

variable "cosmotech_run_api_service_address" {
  type = string
}

variable "cosmotech_run_api_client_id" {
  type = string
}

variable "cosmotech_run_api_client_secret" {
  type = string
}

variable "cluster_domain" {
  type = string
}
