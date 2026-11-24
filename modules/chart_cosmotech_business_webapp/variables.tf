variable "namespace" {
  type = string
}

variable "cluster_domain" {
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

variable "webapp_name" {
  description = "Webapp name, also used as Helm release name and URL path (/<namespace>/<webapp_name>)"
  type        = string
}

variable "asset_data_layer_enabled" {
  description = "Adds RUN_API_URL and ADL_API_URL to the webapp globalConfiguration"
  type        = bool
  default     = false
}

variable "organization_id" {
  type    = string
  default = ""
}

variable "extra_global_configuration" {
  description = "Additional/overriding keys for GlobalConfiguration.json"
  type        = map(any)
  default     = {}
}

variable "registry" {
  type = string
}

variable "registry_auth_secret" {
  type = string
}

variable "image_name_server" {
  type = string
}

variable "image_tag_server" {
  type = string
}

variable "image_name_functions" {
  type = string
}

variable "image_tag_functions" {
  type = string
}

variable "powerbi_tenant_id" {
  type    = string
  default = ""
}

variable "keycloak_client_id" {
  description = "Keycloak client id of the webapp (created by config_keycloak_realm)"
  type        = string
}
