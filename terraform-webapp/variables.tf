locals {
  webapp_name = "webapp-${var.webapp_name}"
  tenant    = "tenant-${var.tenant}"
}

variable "kubernetes_context" {
  description = "Kubernetes context (= the cluster) where to perform installation"
  type        = string
}

variable "tenant" {
  description = "Cosmo Tech tenant name"
  type        = string
}

variable "webapp_name" {
  description = "Webapp name"
  type        = string
}

variable "cluster_domain" {
  description = "[temporary] Cluster domain"
  type        = string
}

variable "organization_id" {
  description = "Organization ID to map with the Webapp"
  type        = string
}