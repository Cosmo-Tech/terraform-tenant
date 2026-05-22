resource "keycloak_openid_client" "cosmotech_web" {
  enabled               = true
  realm_id              = keycloak_realm.realm.id
  client_id             = local.cosmotech_web
  name                  = local.cosmotech_web
  access_type           = local.access_type
  full_scope_allowed    = local.full_scope_allowed
  standard_flow_enabled = local.standard_flow_enabled
  web_origins           = local.web_origins
  root_url              = local.root_url
  base_url              = local.base_url
  valid_redirect_uris   = local.valid_redirect_uris

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_web" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_web.id
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

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_web_groups" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_web.id
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
