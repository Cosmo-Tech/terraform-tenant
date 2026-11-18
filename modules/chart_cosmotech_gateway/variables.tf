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

variable "cosmotech_gateway_image_name" {
  type = string
}

variable "cosmotech_gateway_image_tag" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "keycloak_gateway_client_id" {
  type = string
}

variable "tenant_recipe_modules" {
  type = list(string)
}

variable "cosmotech_run_api_service_address" {
  description = "Formatted: \"<host>:<port>/<path>\""
  type        = string
}
