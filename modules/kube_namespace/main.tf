locals {
  registries = {
    for key, value in {
      chainguard = {
        enabled = true
        secret  = var.image_registry_auth_secret
      }
      cosmotech-modeling-api = {
        enabled = var.cosmotech_modeling_api_image_registry_auth_secret != null
        secret  = var.cosmotech_modeling_api_image_registry_auth_secret
      }
    } : key => value if value.enabled
  }
}


resource "kubernetes_namespace" "tenant" {
  metadata {
    name = "tenant-${var.tenant}"
  }
}


## Authentication for container registries required to allow usage of various images
## These secrets are created in terraform-shared and duplicated here in each tenant namespace

# Get the source secret
data "kubernetes_secret" "registry_auth" {
  for_each = local.registries

  metadata {
    name      = each.value.secret
    namespace = "default"
  }
}

# Create the namespace/tenant copy
resource "kubernetes_secret" "registry_auth" {
  for_each = local.registries

  metadata {
    name      = each.value.secret
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = data.kubernetes_secret.registry_auth[each.key].data[".dockerconfigjson"]
  }

  type = "kubernetes.io/dockerconfigjson"
}
