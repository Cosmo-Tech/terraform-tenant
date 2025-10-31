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
  username  = "user"
  password  = data.kubernetes_secret.keycloak.data["admin-password"]
}


locals {
  cosmotech_api     = "cosmotech-client-api"
  cosmotech_web     = "cosmotech-client-web"
  cosmotech_babylon = "cosmotech-client-babylon"


  # api_version_path = "v${substr(regex("[0-1]", "${data.kubernetes_pod.cosmotech_api.spec[0].container[0].image}"), 0, 1)}"
  api_version_path = "v5"
  

  access_type           = "CONFIDENTIAL"
  full_scope_allowed    = true
  standard_flow_enabled = true
  web_origins           = ["+"]
  root_url              = "https://${var.cluster_domain}"
  base_url              = "/${var.tenant}/${local.api_version_path}/"
  valid_redirect_uris = [
    "https://${var.cluster_domain}/${var.tenant}/${local.api_version_path}/swagger-ui/oauth2-redirect.html",
    "/*"
  ]
}


data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = "keycloak"
    name      = "keycloak"
  }
}


# data "kubernetes_pod" "cosmotech_api" {
#   metadata {
#     name       = "cosmotech-api-${var.tenant}"
#     namespace  = var.tenant
#     # labels = {
#     #   instance = "cosmotech-api-${var.tenant}"
#     # }
#   }
# }


resource "keycloak_realm" "realm" {
  enabled                     = true
  realm                       = var.tenant
  access_code_lifespan        = "30m"
  default_signature_algorithm = "RS256"
}


resource "keycloak_role" "platform_admin" {
  realm_id = keycloak_realm.realm.id
  name     = "Platform.Admin"

  depends_on = [
    keycloak_realm.realm,
  ]
}

resource "keycloak_role" "organization_user" {
  realm_id = keycloak_realm.realm.id
  name     = "Organization.User"

  depends_on = [
    keycloak_realm.realm,
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

# resource "keycloak_generic_protocol_mapper" "api_realm_roles_mapper" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech_api.id
#   name            = "realm roles"
#   protocol        = "openid-connect"
#   protocol_mapper = "oidc-usermodel-realm-role-mapper"
#   config = {
#     "id.token.claim" : "true",
#     "access.token.claim" : "true",
#     "claim.name" : "userRoles",
#     "jsonType.label" : "String",
#     "multivalued" : "true",
#     "userinfo.token.claim" : "true",
#     "introspection.token.claim" : "true"
#   }
# }

# resource "keycloak_openid_client_service_account_realm_role" "client_service_account_role" {
#   realm_id                = keycloak_realm.realm.id
#   service_account_user_id = keycloak_openid_client.cosmotech_api.service_account_user_id
#   role                    = keycloak_role.platform_admin.name

#   depends_on = [
#     keycloak_openid_client.cosmotech_api,
#   ]
# }


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

# resource "keycloak_generic_protocol_mapper" "branch_code_mapper" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech_web.id
#   name            = "BranchCodeMapper"
#   protocol        = "openid-connect"
#   protocol_mapper = "oidc-usermodel-attribute-mapper"
#   config = {
#     "aggregate.attrs" : "false",
#     "multivalued" : "false",
#     "userinfo.token.claim" : "true",
#     "user.attribute" : "branch",
#     "id.token.claim" : "false",
#     "access.token.claim" : "true",
#     "claim.name" : "branch",
#     "jsonType.label" : "String",
#     "introspection.token.claim" : "true"
#   }
# }

# resource "keycloak_generic_protocol_mapper" "email_mapper" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech_web.id
#   name            = "email"
#   protocol        = "openid-connect"
#   protocol_mapper = "oidc-usermodel-property-mapper"
#   config = {
#     "user.attribute" : "email",
#     "id.token.claim" : "true",
#     "access.token.claim" : "true",
#     "claim.name" : "email",
#     "jsonType.label" : "String",
#     "userinfo.token.claim" : "true",
#     "introspection.token.claim" : "true"
#   }
# }

resource "keycloak_generic_protocol_mapper" "realm_roles_mapper" {
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

# resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
#   realm_id  = keycloak_realm.realm.id
#   client_id = keycloak_openid_client.cosmotech_web.id

#   default_scopes = [
#     "web-origins",
#     "acr",
#     "roles",
#     "profile",
#     "basic",
#     "email"
#   ]
# }


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

# Secret that will be used directly from Babylon
resource "kubernetes_secret" "babylon" {
  metadata {
    name      = "keycloak-babylon"
    namespace = var.tenant
  }

  data = {
    "client_id" : keycloak_openid_client.cosmotech_babylon.client_id,
    "client_secret" : keycloak_openid_client.cosmotech_babylon.client_secret,
    "url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/keycloak/realms/${var.tenant}/protocol/openid-connect/token",
    # "grant_type" : "client_credentials",
    # "scope" : "openid",
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_babylon,
  ]
}
