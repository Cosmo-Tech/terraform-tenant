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

variable "image_registry" {
  type = string
}

variable "image_registry_auth_secret" {
  type = string
}

variable "image_repository_prefix" {
  type = string
}

variable "cosmotech_asset_data_layer_image_tag" {
  type = string
}

variable "postgresql_host" {
  type = string
}

variable "postgresql_port" {
  type = string
}

variable "postgresql_database" {
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

variable "cosmotech_api_client_id" {
  type = string
}

variable "cosmotech_api_client_secret" {
  type = string
}

variable "cluster_domain" {
  type = string
}
