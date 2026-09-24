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

variable "seaweedfs_image_name" {
  type = string
}

variable "seaweedfs_image_tag" {
  type = string
}

variable "postgresql_image_name" {
  type = string
}

variable "postgresql_image_tag" {
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

variable "pvc_master_access_modes" {
  type = string
}

variable "size_volume" {
  type = string
}

variable "pvc_volume" {
  type = string
}

variable "pvc_volume_storage_class" {
  type = string
}

variable "pvc_volume_access_modes" {
  type = string
}

variable "database_host" {
  type = string
}

variable "database_port" {
  type = string
}
