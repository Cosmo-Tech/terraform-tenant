variable "namespace" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "cosmotech_run_api_route_suffix" {
  description = "Gateway path segment under which the Run API is exposed"
  type        = string
}

variable "tenant_recipe_modules" {
  type = list(string)
}

variable "webapp_name" {
  type = string
}

variable "mcp_enabled" {
  type = bool
}
