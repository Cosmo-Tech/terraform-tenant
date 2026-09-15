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

variable "postgresql_host" {
  type = string
}

variable "postgresql_port" {
  type = string
}

variable "postgresql_database" {
  type = string
}

variable "cluster_domain" {
  type = string
}
