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

variable "image_tag" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "pvc_storage_class" {
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

variable "postgresql_username" {
  type = string
}

variable "postgresql_password" {
  type = string
}
