variable "tenant" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "superset_namespace" {
  type = string
  default = "superset"
}

variable "superset_oauth_providers_configmap_name" {
  type = string
  default = "superset-oauth-providers"
}

variable "superset_keycloak_client_name" {
  type = string
  default = "cosmotech-client-superset"
}

variable "cosmotech_superset_client_secret" {
  type = string
}