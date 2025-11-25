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
  username  = data.kubernetes_secret.keycloak.data["keycloak_admin_user"]
  password  = data.kubernetes_secret.keycloak.data["keycloak_admin_password"]
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
    "token_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/keycloak/realms/${var.tenant}/protocol/openid-connect/token",
    "api_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/${var.tenant}/api",
    # "grant_type" : "client_credentials",
    # "scope" : "openid",
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_babylon,
  ]
}


resource "keycloak_group" "group_admin" {
  realm_id = keycloak_realm.realm.id
  name     = "${var.tenant}-admin"
}


resource "keycloak_group" "group_editor" {
  realm_id = keycloak_realm.realm.id
  name     = "${var.tenant}-editor"
}


resource "keycloak_group" "group_viewer" {
  realm_id = keycloak_realm.realm.id
  name     = "${var.tenant}-viewer"
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