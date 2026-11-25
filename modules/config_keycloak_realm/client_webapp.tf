## Keycloak client for the Cosmo Tech Business Webapp (only created when webapp_name is set)
locals {
  cosmotech_webapp_base_url = var.webapp_name != null ? "https://${var.cluster_domain}/${var.namespace}/${var.webapp_name}" : null
}


resource "keycloak_openid_client" "cosmotech_webapp" {
  count = var.webapp_name != null ? 1 : 0

  enabled               = true
  realm_id              = keycloak_realm.realm.id
  client_id             = local.cosmotech_webapp
  name                  = local.cosmotech_webapp
  access_type           = "PUBLIC"
  full_scope_allowed    = true
  standard_flow_enabled = true
  root_url              = local.root_url
  base_url              = local.cosmotech_webapp_base_url
  web_origins = [
    local.root_url,
  ]
  valid_redirect_uris = [
    "${local.cosmotech_webapp_base_url}/sign-in",
    "${local.cosmotech_webapp_base_url}/*",
  ]

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_openid_client_default_scopes" "cosmotech_webapp_default_scopes" {
  count = var.webapp_name != null ? 1 : 0

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.cosmotech_webapp[0].id

  default_scopes = [
    "acr",
    "basic",
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.mcp_client_scope.name,
  ]
}

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_webapp" {
  count = var.webapp_name != null ? 1 : 0

  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_webapp[0].id
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

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_webapp_groups" {
  count = var.webapp_name != null ? 1 : 0

  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_webapp[0].id
  name            = "groups"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-realm-role-mapper"
  config = {
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "groups",
    "jsonType.label" : "String",
    "multivalued" : "true",
    "userinfo.token.claim" : "true",
    "introspection.token.claim" : "true"
  }
}
