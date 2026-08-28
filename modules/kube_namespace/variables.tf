variable "tenant_namespace" {
  description = "Cosmo Tech tenant namespace"
  type        = string
}

variable "tenant_type" {
  description = "Cosmo Tech tenant type"
  type        = string
}

variable "image_registry_auth_secret" {
  description = "Kubernetes secret that contains the image registry authentication"
  type        = string
}

variable "use_external_postgresql" {
  type = string
}