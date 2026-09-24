resource "keycloak_openid_client" "cosmotech_api" {
  enabled                  = true
  realm_id                 = keycloak_realm.realm.id
  client_id                = local.cosmotech_api
  name                     = local.cosmotech_api
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

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_api" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_api.id
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

resource "keycloak_openid_client_service_account_realm_role" "cosmotech_api_service_account_role" {
  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.cosmotech_api.service_account_user_id
  role                    = keycloak_role.platform_admin.name
}
