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

variable "cosmotech_asset_investment_planning_api_image_name" {
  type = string
}

variable "cosmotech_asset_investment_planning_api_image_tag" {
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

variable "cluster_domain" {
  type = string
}
