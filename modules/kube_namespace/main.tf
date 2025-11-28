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

resource "kubernetes_secret" "terraform_module_tag" {
  metadata {
    name      = "cosmotech-terraform-module-tag"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  data = {
    "module" : "terraform-tenant",
    "tag" : "todo",
  }

  type = "Opaque"
}
