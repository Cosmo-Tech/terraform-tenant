terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.5.0"
    }
  }
}


provider "keycloak" {
  url       = "https://${var.cluster_domain}/keycloak/"
  client_id = "admin-cli"
  # username  = "admin"
  username = data.kubernetes_secret.keycloak.data["keycloak_admin_user"]
  password = data.kubernetes_secret.keycloak.data["keycloak_admin_password"]
}


locals {
  cosmotech_api     = "cosmotech-client-api"
  cosmotech_web     = "cosmotech-client-web"
  cosmotech_babylon = "cosmotech-client-babylon"

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


data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = "keycloak"
    name      = "keycloak-config"
  }
}


resource "keycloak_realm" "realm" {
  enabled                     = true
  realm                       = var.tenant
  access_code_lifespan        = "30m"
  default_signature_algorithm = "RS256"
}


# Organization.User
resource "keycloak_role" "organization_user" {
  realm_id = keycloak_realm.realm.id
  name     = "Organization.User"

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_group" "organization_user" {
  realm_id = keycloak_realm.realm.id
  name     = "organization_user"
}

resource "keycloak_group_roles" "organization_user" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.organization_user.id

  role_ids = [
    keycloak_role.organization_user.id,
  ]

  depends_on = [
    keycloak_group.organization_user,
    keycloak_role.organization_user
  ]
}


# Platform.Admin
resource "keycloak_role" "platform_admin" {
  realm_id = keycloak_realm.realm.id
  name     = "Platform.Admin"

  depends_on = [
    keycloak_realm.realm,
  ]
}

# The group is placed under Organization.User
resource "keycloak_group" "platform_admin" {
  realm_id  = keycloak_realm.realm.id
  parent_id = keycloak_group.organization_user.id
  name      = "platform_admin"

  depends_on = [
    keycloak_group.organization_user
  ]
}

resource "keycloak_group_roles" "platform_admin" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.platform_admin.id

  role_ids = [
    keycloak_role.platform_admin.id,
  ]

  depends_on = [
    keycloak_group.platform_admin,
    keycloak_role.platform_admin
  ]
}


resource "keycloak_openid_client" "cosmotech_api" {
  enabled               = true
  realm_id              = keycloak_realm.realm.id
  client_id             = local.cosmotech_api
  name                  = local.cosmotech_api
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


resource "keycloak_openid_client" "cosmotech_babylon" {
  enabled               = true
  realm_id              = keycloak_realm.realm.id
  client_id             = local.cosmotech_babylon
  name                  = local.cosmotech_babylon
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
    "grant_type" : "client_credentials",
    "scope" : "openid",
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_babylon,
  ]
}


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