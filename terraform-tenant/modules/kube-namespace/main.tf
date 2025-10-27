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


resource "kubernetes_secret" "harbor" {
  metadata {
    name      = "cosmotech-harbor"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

  type = "Opaque"
}

resource "kubernetes_secret" "keycloak" {
  metadata {
    name      = "cosmotech-keycloak"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

  type = "Opaque"
}

resource "kubernetes_secret" "babylon" {
  metadata {
    name      = "cosmotech-babylon"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

  data = {
    "client_id" : "cosmotech-babylon-client",
    "client_secret" : random_password.password.result,
    "grant_type" : "client_credentials",
    "scope" : "openid",
    "url" : "https://KEYCLOAK_URL/keycloak/realms/TENANT/protocol/openid-connect/token"
  }

  type = "Opaque"
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


