data "kubernetes_namespace" "tenant_existing" {
  metadata {
    name = var.tenant_namespace
  }
}

# Simple security to preserve tenants integrity
resource "terraform_data" "prevent_tenant_type_change" {
  lifecycle {
    precondition {
      condition     = (try(data.kubernetes_namespace.tenant_existing.metadata[0].annotations["cosmotech.com/tenant-type"], var.tenant_type) == var.tenant_type)
      error_message = "Forbidden deployment: variable 'tenant_type' (=${var.tenant_type}) cannot be changed, and currently does not match existing value (=${try(data.kubernetes_namespace.tenant_existing.metadata[0].annotations["cosmotech.com/tenant-type"], "unknown")}). Please consider rename your tenant with a free name, or manually edit the namespace annotation."
    }
  }
}

# Simple security to preserve tenants integrity
resource "terraform_data" "prevent_database_change" {
  lifecycle {
    precondition {
      condition     = (try(data.kubernetes_namespace.tenant_existing.metadata[0].annotations["cosmotech.com/use-external-database"], var.use_external_postgresql) == var.use_external_postgresql)
      error_message = "Forbidden deployment: variable 'use_external_postgresql' (=${var.use_external_postgresql}) cannot be changed, and currently does not match existing value (=${try(data.kubernetes_namespace.tenant_existing.metadata[0].annotations["cosmotech.com/use-external-database"], "unknown")}). Please consider rename your tenant with a free name, or manually edit the namespace annotation."
    }
  }
}


resource "kubernetes_namespace" "tenant" {
  metadata {
    name = var.tenant_namespace
    annotations = {
      "cosmotech.com/tenant-type"           = var.tenant_type
      "cosmotech.com/use-external-database" = var.use_external_postgresql # true/false
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    terraform_data.prevent_tenant_type_change,
    terraform_data.prevent_database_change,
  ]
}


resource "random_password" "password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  min_special = 5
}



## Authentication to image registries is required to allow Kubernetes pulling images
## These secrets are created in terraform-shared
## -> Getting all secrets from default namespace
data "kubernetes_resources" "registry_auth_secrets" {
  api_version = "v1"
  kind        = "Secret"
  namespace   = "default"
}

## -> Filtering secrets starting with "registry-auth"
locals {
  matching_registry_auth_secrets = {
    for secret in data.kubernetes_resources.registry_auth_secrets.objects :
    secret.metadata.name => secret
    if startswith(secret.metadata.name, "registry-auth")
  }
}

## -> Paste the filtered secrets in the tenant namespace
resource "kubernetes_secret_v1" "registry_auth" {
  for_each = local.matching_registry_auth_secrets

  metadata {
    name      = each.key
    namespace = var.tenant_namespace
    labels    = lookup(each.value.metadata, "labels", null)
  }

  type = lookup(each.value, "type", "Opaque")

  binary_data = {
    for k, v in lookup(each.value, "data", {}) : k => v
  }

  depends_on = [
    kubernetes_namespace.tenant
  ]
}
