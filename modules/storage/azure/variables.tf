variable "tenant" {
  type = string
}

variable "resource" {
  description = "Name of the resource that needs the persistent storage"
  type        = string
}

variable "size" {
  description = "Size of the disk/pv/pvc"
  type        = number
}

variable "storage_class_name" {
  description = "Storage class for disk/pv/pvc"
  type        = string
}

variable "region" {
  type = string
}

# variable "azure_subscription_id" {
#   description = "[temporary] Azure subscription ID"
#   type        = string
# }

# variable "resource_group" {
#   type = string
# }

variable "cluster_name" {
  type = string
}

variable "cloud_provider" {
  type = string
}