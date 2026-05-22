resource "random_password" "keycloak_superset_secret" {
  length  = 40
  special = false
}

resource "keycloak_openid_client" "cosmotech_superset" {
  enabled                  = true
  realm_id                 = keycloak_realm.realm.id
  client_id                = local.cosmotech_superset
  client_secret            = random_password.keycloak_superset_secret.result
  name                     = local.cosmotech_superset
  access_type              = local.access_type
  full_scope_allowed       = local.full_scope_allowed
  standard_flow_enabled    = local.standard_flow_enabled
  service_accounts_enabled = true
  web_origins              = ["https://${var.cluster_domain}", "https://superset-${var.cluster_domain}"]
  root_url                 = "https://superset-${var.cluster_domain}"
  valid_redirect_uris = [
    "https://${var.cluster_domain}/oauth-authorized/${var.tenant}",
    "https://superset-${var.cluster_domain}/oauth-authorized/${var.tenant}",
    "http://${var.cluster_domain}/oauth-authorized/${var.tenant}",
    "http://superset-${var.cluster_domain}/oauth-authorized/${var.tenant}",
  ]

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_superset" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech_superset.id
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

resource "kubernetes_secret" "keycloak_superset_client_secret" {
  metadata {
    name      = "keycloak-superset"
    namespace = var.tenant
  }

  data = {
    client-secret = keycloak_openid_client.cosmotech_superset.client_secret,
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_superset,
  ]
}
