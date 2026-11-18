resource "keycloak_openid_client" "cosmotech_gateway" {
  enabled               = true
  realm_id              = keycloak_realm.realm.id
  client_id             = local.cosmotech_gateway
  name                  = local.cosmotech_gateway
  access_type           = "PUBLIC"
  full_scope_allowed    = local.full_scope_allowed
  standard_flow_enabled = local.standard_flow_enabled
  web_origins           = local.web_origins
  root_url              = local.root_url
  base_url              = local.base_gateway_url
  valid_redirect_uris = [
    "https://${var.cluster_domain}/${var.namespace}/*",
  ]
  service_accounts_enabled   = false
  pkce_code_challenge_method = "S256"

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_gateway" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_gateway.id
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
