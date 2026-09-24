terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
    }
  }
}


resource "keycloak_openid_client" "client" {
  enabled               = true
  realm_id              = var.namespace
  client_id             = local.keycloak_client_id
  name                  = local.keycloak_client_id
  access_type           = "PUBLIC"
  full_scope_allowed    = true
  standard_flow_enabled = true
  root_url              = "https://${var.cluster_domain}"
  base_url              = "https://${var.cluster_domain}/${var.namespace}/webapp"
  web_origins = [
    "https://${var.cluster_domain}"
  ]
  valid_redirect_uris = [
    "https://${var.cluster_domain}/${var.namespace}/webapp/sign-in",
    "https://${var.cluster_domain}/${var.namespace}/webapp/*"
  ]
}

resource "keycloak_generic_protocol_mapper" "realm_roles_mapper" {
  realm_id        = var.namespace
  client_id       = keycloak_openid_client.client.id
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

resource "keycloak_generic_protocol_mapper" "realm_roles_mapper_groups" {
  realm_id        = var.namespace
  client_id       = keycloak_openid_client.client.id
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
