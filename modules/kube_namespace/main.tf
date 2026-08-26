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
      error_message = "Forbidden deployment: variable 'tenant_type' (${var.tenant_type}) cannot be changed, and currently does not match existing tenant type (${try(data.kubernetes_namespace.tenant_existing.metadata[0].annotations["cosmotech.com/tenant-type"], "unknown")})."
    }
  }
}


resource "kubernetes_namespace" "tenant" {
  metadata {
    name = var.tenant_namespace
    annotations = {
      "cosmotech.com/tenant-type" = var.tenant_type
      "cosmotech.com/use-external-database" = var.use_external_postgresql # true/false
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    terraform_data.prevent_tenant_type_change
  ]
}


resource "random_password" "password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  min_special = 5
}


## Authentication to Image Registry is required to allow usage of sub-images in Charts
## This secret is created in terraform-shared
## -> Copy the registry auth secret
data "kubernetes_secret" "registry_auth" {
  metadata {
    name      = var.image_registry_auth_secret
    namespace = "default"
  }
}

## -> Paste the registry auth secret in the tenant namespace
resource "kubernetes_secret" "registry_auth" {
  metadata {
    name      = data.kubernetes_secret.registry_auth.metadata[0].name
    namespace = var.tenant_namespace
  }

  data = {
    ".dockerconfigjson" = data.kubernetes_secret.registry_auth.data[".dockerconfigjson"]
  }

  type = "kubernetes.io/dockerconfigjson"


  depends_on = [
    kubernetes_namespace.tenant,
    data.kubernetes_secret.registry_auth
  ]
}
