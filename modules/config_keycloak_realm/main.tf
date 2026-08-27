terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
    }
  }
}


locals {
  cosmotech_api      = "cosmotech-client-api"
  cosmotech_web      = "cosmotech-client-web"
  cosmotech_babylon  = "cosmotech-client-babylon"
  cosmotech_superset = "cosmotech-client-superset"

  access_type           = "CONFIDENTIAL"
  full_scope_allowed    = true
  standard_flow_enabled = true
  web_origins           = ["+"]
  root_url              = "https://${var.cluster_domain}"
  base_url              = "/${var.tenant}/api/"
  valid_redirect_uris = [
    "https://${var.cluster_domain}/${var.tenant}/api/swagger-ui/oauth2-redirect.html",
    "/*"
  ]
}


resource "keycloak_realm" "realm" {
  enabled                     = true
  realm                       = var.tenant
  access_code_lifespan        = "30m"
  default_signature_algorithm = "RS256"
}


# --- Mapper for API ACL ---
data "keycloak_openid_client_scope" "client_scope_profile" {
  realm_id = keycloak_realm.realm.id
  name     = "profile"
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = data.keycloak_openid_client_scope.client_scope_profile.id
  name            = "cosmotech-api-groups"

  full_path = false

  claim_name = "groups"
}
# --- Mapper for API ACL ---
