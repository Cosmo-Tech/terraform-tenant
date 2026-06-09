locals {
  main_name = "tenant-${var.tenant}"
}


resource "kubernetes_namespace" "tenant" {
  metadata {
    name = local.main_name
  }
}


resource "random_password" "password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  min_special = 5
}



## Secret to store the version of the Terraform module of the tenant
# resource "kubernetes_secret" "terraform_module_tag" {
#   metadata {
#     name      = "cosmotech-terraform-module-tag"
#     namespace = kubernetes_namespace.tenant.metadata[0].name
#   }

#   data = {
#     "module" : "terraform-tenant",
#     "tag" : "todo",
#   }

#   type = "Opaque"
# }



## Authentication to Image Registry is required to allow usage of sub-images in Charts
## This secret is created in terraform-shared

## Copy the registry auth secret
data "kubernetes_secret" "registry_auth" {
  metadata {
    name      = var.image_registry_auth_secret
    namespace = "default"
  }
}

## Paste the registry auth secret in the tenant namespace
resource "kubernetes_secret" "registry_auth" {
  metadata {
    name      = data.kubernetes_secret.registry_auth.metadata[0].name
    namespace = local.main_name
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
