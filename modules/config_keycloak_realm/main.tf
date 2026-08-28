terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.7.0"
    }
  }
}


provider "keycloak" {
  url       = "https://${var.cluster_domain}/keycloak"
  client_id = "admin-cli"
  username  = data.kubernetes_secret.keycloak.data["keycloak_admin_user"]
  password  = data.kubernetes_secret.keycloak.data["keycloak_admin_password"]
}


locals {
  cosmotech_api      = "cosmotech-client-api"
  cosmotech_web      = "cosmotech-client-web"
  cosmotech_babylon  = "cosmotech-client-babylon"
  cosmotech_superset = "cosmotech-client-superset"
  cosmotech_admin    = "cosmotech-client-admin"

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


# # --- Role Organization.User ---
# resource "keycloak_role" "organization_user" {
#   realm_id = keycloak_realm.realm.id
#   name     = "Organization.User"

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# resource "keycloak_group" "organization_user" {
#   realm_id = keycloak_realm.realm.id
#   name     = "organization_user"
# }

# resource "keycloak_group_roles" "organization_user" {
#   realm_id = keycloak_realm.realm.id
#   group_id = keycloak_group.organization_user.id

#   role_ids = [
#     keycloak_role.organization_user.id,
#   ]

#   depends_on = [
#     keycloak_group.organization_user,
#     keycloak_role.organization_user
#   ]
# }
# # --- Role Organization.User ---


# # -- Role Platform.Admin ---
# resource "keycloak_role" "platform_admin" {
#   realm_id = keycloak_realm.realm.id
#   name     = "Platform.Admin"

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# # The group platform_admin is placed under the group organization_user
# resource "keycloak_group" "platform_admin" {
#   realm_id  = keycloak_realm.realm.id
#   parent_id = keycloak_group.organization_user.id
#   name      = "platform_admin"

#   depends_on = [
#     keycloak_group.organization_user
#   ]
# }

# resource "keycloak_group_roles" "platform_admin" {
#   realm_id = keycloak_realm.realm.id
#   group_id = keycloak_group.platform_admin.id

#   role_ids = [
#     keycloak_role.platform_admin.id,
#   ]

#   depends_on = [
#     keycloak_group.platform_admin,
#     keycloak_role.platform_admin
#   ]
# }
# # -- Role Platform.Admin ---


# # --- Client cosmotech-client-api ---
# resource "keycloak_openid_client" "cosmotech_api" {
#   enabled                  = true
#   realm_id                 = keycloak_realm.realm.id
#   client_id                = local.cosmotech_api
#   name                     = local.cosmotech_api
#   access_type              = local.access_type
#   full_scope_allowed       = local.full_scope_allowed
#   standard_flow_enabled    = local.standard_flow_enabled
#   web_origins              = local.web_origins
#   root_url                 = local.root_url
#   base_url                 = local.base_url
#   valid_redirect_uris      = local.valid_redirect_uris
#   service_accounts_enabled = true

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_api" {
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

# resource "keycloak_openid_client_service_account_realm_role" "cosmotech_api_service_account_role" {
#   realm_id                = keycloak_realm.realm.id
#   service_account_user_id = keycloak_openid_client.cosmotech_api.service_account_user_id
#   role                    = keycloak_role.platform_admin.name
# }
# # --- Client cosmotech-client-api ---


# # --- Client cosmotech-client-web ---
# resource "keycloak_openid_client" "cosmotech_web" {
#   enabled               = true
#   realm_id              = keycloak_realm.realm.id
#   client_id             = local.cosmotech_web
#   name                  = local.cosmotech_web
#   access_type           = local.access_type
#   full_scope_allowed    = local.full_scope_allowed
#   standard_flow_enabled = local.standard_flow_enabled
#   web_origins           = local.web_origins
#   root_url              = local.root_url
#   base_url              = local.base_url
#   valid_redirect_uris   = local.valid_redirect_uris

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_web" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech_web.id
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

# resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_web_groups" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech_web.id
#   name            = "groups"
#   protocol        = "openid-connect"
#   protocol_mapper = "oidc-usermodel-realm-role-mapper"
#   config = {
#     "id.token.claim" : "true",
#     "access.token.claim" : "true",
#     "claim.name" : "groups",
#     "jsonType.label" : "String",
#     "multivalued" : "true",
#     "userinfo.token.claim" : "true",
#     "introspection.token.claim" : "true"
#   }
# }
# # --- Client cosmotech-client-web ---


# # --- Client cosmotech-client-superset ---
# resource "random_password" "keycloak_superset_secret" {
#   length  = 40
#   special = false
# }

# resource "keycloak_openid_client" "cosmotech_superset" {
#   enabled                  = true
#   realm_id                 = keycloak_realm.realm.id
#   client_id                = local.cosmotech_superset
#   client_secret            = random_password.keycloak_superset_secret.result
#   name                     = local.cosmotech_superset
#   access_type              = local.access_type
#   full_scope_allowed       = local.full_scope_allowed
#   standard_flow_enabled    = local.standard_flow_enabled
#   service_accounts_enabled = true
#   web_origins              = ["https://${var.cluster_domain}", "https://superset-${var.cluster_domain}"]
#   root_url                 = "https://superset-${var.cluster_domain}"
#   valid_redirect_uris = [
#     "https://${var.cluster_domain}/oauth-authorized/${var.tenant}",
#     "https://superset-${var.cluster_domain}/oauth-authorized/${var.tenant}",
#     "http://${var.cluster_domain}/oauth-authorized/${var.tenant}",
#     "http://superset-${var.cluster_domain}/oauth-authorized/${var.tenant}",
#   ]

#   depends_on = [
#     keycloak_realm.realm,
#     kubernetes_secret.keycloak_superset_client_secret
#   ]
# }

# resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_superset" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech_superset.id
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

# resource "kubernetes_secret" "keycloak_superset_client_secret" {
#   metadata {
#     name      = "keycloak-superset"
#     namespace = var.tenant
#   }

#   data = {
#     "client_secret" : keycloak_openid_client.cosmotech_superset.client_secret,
#   }

#   type = "Opaque"

#   depends_on = [
#     keycloak_openid_client.cosmotech_superset,
#   ]
# }
# # --- Client cosmotech-client-superset ---


# # --- Client cosmotech-client-babylon ---
# resource "keycloak_openid_client" "cosmotech_babylon" {
#   enabled                  = true
#   realm_id                 = keycloak_realm.realm.id
#   client_id                = local.cosmotech_babylon
#   name                     = local.cosmotech_babylon
#   access_type              = local.access_type
#   full_scope_allowed       = local.full_scope_allowed
#   standard_flow_enabled    = local.standard_flow_enabled
#   web_origins              = local.web_origins
#   root_url                 = local.root_url
#   base_url                 = local.base_url
#   valid_redirect_uris      = local.valid_redirect_uris
#   service_accounts_enabled = true

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# resource "keycloak_generic_protocol_mapper" "mapper_cosmotech_babylon" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech_babylon.id
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

# resource "keycloak_openid_client_service_account_realm_role" "cosmotech_babylon_service_account_role" {
#   realm_id                = keycloak_realm.realm.id
#   service_account_user_id = keycloak_openid_client.cosmotech_babylon.service_account_user_id
#   role                    = keycloak_role.platform_admin.name
# }


# # Secret that will be used directly from Babylon
# resource "kubernetes_secret" "babylon" {
#   metadata {
#     name      = "keycloak-babylon"
#     namespace = var.tenant
#   }

#   data = {
#     "client_id" : keycloak_openid_client.cosmotech_babylon.client_id,
#     "client_secret" : keycloak_openid_client.cosmotech_babylon.client_secret,
#     "token_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/keycloak/realms/${var.tenant}/protocol/openid-connect/token",
#     "api_url" : "${keycloak_openid_client.cosmotech_babylon.root_url}/${var.tenant}/api",
#   }

#   type = "Opaque"

#   depends_on = [
#     keycloak_openid_client.cosmotech_babylon,
#   ]
# }
# # --- Client cosmotech-client-babylon ---
