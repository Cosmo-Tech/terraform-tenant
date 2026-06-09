variable "tenant" {
  type = string
}

variable "image_registry" {
  type = string
}

variable "image_registry_auth_secret" {
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

variable "size" {
  type = string
}

variable "pvc" {
  type = string
}

variable "pvc_storage_class" {
  type = string
}

variable "postgresql_image_repository" {
  type = string
}

variable "postgresql_image_tag" {
  type = string
}
