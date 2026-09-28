resource "keycloak_openid_client_scope" "mcp_client_scope" {
  realm_id               = keycloak_realm.realm.id
  name                   = "mcp"
  description            = "When provided, this scope allows MCP endpoint calls"
  include_in_token_scope = true
}

resource "keycloak_openid_client" "cosmotech_api_mcp" {
  enabled               = true
  realm_id              = keycloak_realm.realm.id
  client_id             = local.cosmotech_api_mcp
  name                  = local.cosmotech_api_mcp
  access_type           = "PUBLIC"
  full_scope_allowed    = true
  standard_flow_enabled = true
  web_origins           = local.web_origins
  root_url              = local.root_url
  base_url              = local.base_mcp_url
  valid_redirect_uris = [
    "http://127.0.0.1:33418/*",
    # "https://vscode.dev/redirect",
    # "https://claude.ai/api/mcp/auth_callback",
  ]
  service_accounts_enabled   = false
  pkce_code_challenge_method = "S256"

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.cosmotech_api_mcp.id

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

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_api_mcp" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_api_mcp.id
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
