variable "namespace" {
  type = string
}

variable "registry" {
  type = string
}

variable "registry_auth_secret" {
  type = string
}

variable "postgresql_image_name" {
  type = string
}

variable "postgresql_image_tag" {
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
