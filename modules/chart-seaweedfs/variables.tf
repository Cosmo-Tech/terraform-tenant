variable "tenant" {
  type = string
}

variable "release" {
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

variable "database_seaweedfs_name" {
  type = string
}

variable "database_seaweedfs_user" {
  type = string
}

variable "database_seaweedfs_secret" {
  type = string
}

