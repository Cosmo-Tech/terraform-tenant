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


# Secret that will be used directly from Babylon
resource "kubernetes_secret" "babylon" {
  metadata {
    name      = "keycloak-babylon"
    namespace = var.tenant
  }

  data = {
    "client_id" : keycloak_openid_client.cosmotech_babylon.client_id,
    "client_secret" : keycloak_openid_client.cosmotech_babylon.client_secret,
    "token_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/keycloak/realms/${var.tenant}/protocol/openid-connect/token",
    "api_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/${var.tenant}/api",
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_babylon,
  ]
}