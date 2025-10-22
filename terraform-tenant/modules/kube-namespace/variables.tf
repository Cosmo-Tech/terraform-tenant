locals {
  main_name = "tenant-${var.tenant_name}"
}

variable "tenant_name" {
  description = "Cosmo Tech tenant name"
  type        = string
}
