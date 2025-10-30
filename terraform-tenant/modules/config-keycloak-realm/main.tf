terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
      version = "~> 5.5.0"
    }
  }
}

provider "keycloak" {
  url           = "https://${var.cluster_domain}/keycloak/"
  client_id     = "admin-cli"
  username      = "user"
  password      = data.kubernetes_secret.keycloak.data["admin-password"]
}


locals {
  client_name_api     = "cosmotech-client-api"
  client_name_babylon = "cosmotech-client-babylon"
}


data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = "keycloak-temp"
    name      = "keycloak"
  }
}


resource "keycloak_realm" "realm" {
  enabled                     = true
  realm                       = var.tenant
  access_code_lifespan        = "30m"
  default_signature_algorithm = "RS256"
}


resource "keycloak_role" "platform_admin" {
  realm_id = keycloak_realm.realm.id
  name     = "Platform.Admin"

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_role" "organization_user" {
  realm_id = keycloak_realm.realm.id
  name     = "Organization.User"

  depends_on = [
    keycloak_realm.realm,
  ]
}


resource "keycloak_openid_client" "cosmotech_api_client" {
  enabled                  = true
  realm_id                 = keycloak_realm.realm.id
  client_id                = local.client_name_api
  name                     = local.client_name_api
  access_type              = "CONFIDENTIAL"
  standard_flow_enabled    = true
  service_accounts_enabled = true
  root_url                 = "https://${var.cluster_domain}"

  depends_on = [
    keycloak_realm.realm,
  ]
}


resource "keycloak_openid_client" "cosmotech_babylon_client" {
  enabled                  = true
  realm_id                 = keycloak_realm.realm.id
  client_id                = local.client_name_babylon
  name                     = local.client_name_babylon
  access_type              = "CONFIDENTIAL"
  standard_flow_enabled    = false
  service_accounts_enabled = true
  root_url                 = "https://${var.cluster_domain}"

  depends_on = [
    keycloak_realm.realm,
  ]
}

# Secret that will be used directly from Babylon
resource "kubernetes_secret" "babylon" {
  metadata {
    name      = "keycloak-babylon"
    namespace = var.tenant
  }

  data = {
    "client_id" : keycloak_openid_client.cosmotech_babylon_client.client_id,
    "client_secret" : keycloak_openid_client.cosmotech_babylon_client.client_secret,
    # "grant_type" : "client_credentials",
    # "scope" : "openid",
    "url" : "${keycloak_openid_client.cosmotech_babylon_client.client_id}/realms/${var.tenant}/protocol/openid-connect/token"
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_babylon_client,
  ]
}
