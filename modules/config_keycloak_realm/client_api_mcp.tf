## MCP client: all resources are created only when mcp_enabled = true

resource "keycloak_openid_client" "cosmotech_api_mcp" {
  count = var.mcp_enabled ? 1 : 0

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
  count = var.mcp_enabled ? 1 : 0

  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.cosmotech_api_mcp[0].id

  default_scopes = [
    "acr",
    "basic",
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.mcp_client_scope[0].name,
  ]
}

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_api_mcp" {
  count = var.mcp_enabled ? 1 : 0

  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_api_mcp[0].id
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
