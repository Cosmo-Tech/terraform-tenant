resource "keycloak_openid_client" "cosmotech_babylon" {
  enabled                  = true
  realm_id                 = keycloak_realm.realm.id
  client_id                = local.cosmotech_babylon
  name                     = local.cosmotech_babylon
  access_type              = local.access_type
  full_scope_allowed       = local.full_scope_allowed
  standard_flow_enabled    = local.standard_flow_enabled
  web_origins              = local.web_origins
  root_url                 = local.root_url
  base_url                 = local.base_url
  valid_redirect_uris      = local.valid_redirect_uris
  service_accounts_enabled = true

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_babylon" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_babylon.id
  name            = "realm roles"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-realm-role-mapper"
  config = {
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "userRoles",
    "jsonType.label" : "String",
    "multivalued" : "true",
    "userinfo.token.claim" : "true",
    "introspection.token.claim" : "true"
  }
}

resource "keycloak_openid_client_service_account_realm_role" "cosmotech_babylon_service_account_role" {
  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.cosmotech_babylon.service_account_user_id
  role                    = keycloak_role.platform_admin.name
}


data "kubernetes_secret" "superset" {
  metadata {
    namespace = "superset"
    name      = "superset"
  }
}


# Secret that will be used directly from Babylon
resource "kubernetes_secret" "babylon" {
  metadata {
    name      = "babylon-config"
    namespace = var.tenant
  }

  data = {
    "api_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/${var.tenant}/api",
    "keycloak_token_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/keycloak/realms/${var.tenant}/protocol/openid-connect/token",
    "keycloak_client_id" : keycloak_openid_client.cosmotech_babylon.client_id,
    "keycloak_client_secret" : keycloak_openid_client.cosmotech_babylon.client_secret,
    "superset_url" : "https://superset-${var.cluster_domain}",
    "superset_admin_username" : "admin",
    "superset_admin_password" : data.kubernetes_secret.superset.data.superset-password,
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_babylon,
  ]
}