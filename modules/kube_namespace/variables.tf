variable "tenant" {
  description = "Cosmo Tech tenant name"
  type        = string
}

variable "image_registry_auth_secret" {
  description = "Kubernetes secret that contains the image registry authentication"
  type        = string
}

variable "cosmotech_modeling_api_image_registry_auth_secret" {
  description = "Kubernetes secret that contains the image registry authentication for the Cosmo Tech Modeling API"
  type        = string
}
