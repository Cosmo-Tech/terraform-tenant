locals {
  main_name = "tenant-${var.tenant}"
}

variable "tenant" {
  description = "Cosmo Tech tenant name"
  type        = string
}
