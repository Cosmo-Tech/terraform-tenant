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

variable "redis_image_name" {
  type = string
}

variable "redis_image_tag" {
  type = string
}

variable "generic_shell_image_name" {
  type = string
}

variable "generic_shell_image_tag" {
  type = string
}

variable "size_master" {
  type = string
}

variable "pvc_master" {
  type = string
}

variable "pvc_master_storage_class" {
  type = string
}

variable "size_replica" {
  type = string
}

variable "pvc_replica" {
  type = string
}

variable "pvc_replica_storage_class" {
  type = string
}
