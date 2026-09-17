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

variable "argo_workflows_image_prefix" {
  type = string
}

variable "argo_workflows_image_tag" {
  type = string
}

variable "postgresql_image_name" {
  type = string
}

variable "postgresql_image_tag" {
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

variable "database_user" {
  type = string
}

variable "database_secret" {
  type = string
}

variable "s3_host" {
  type = string
}

variable "s3_port" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_secret" {
  type = string
}

variable "s3_secret_key_username" {
  type = string
}

variable "s3_secret_key_password" {
  type = string
}
