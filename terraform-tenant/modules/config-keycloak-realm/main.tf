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


# locals {
#   client_name_api     = "cosmotech-client-api"
#   client_name_babylon = "cosmotech-client-babylon"
# }


# data "kubernetes_secret" "keycloak" {
#   metadata {
#     namespace = "keycloak-temp"
#     name      = "keycloak"
#   }
# }


resource "keycloak_realm" "realm" {
  enabled                     = true
  realm                       = var.tenant
  access_code_lifespan        = "30m"
  default_signature_algorithm = "RS256"
}


# resource "keycloak_role" "platform_admin" {
#   realm_id = keycloak_realm.realm.id
#   name     = "Platform.Admin"

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# resource "keycloak_role" "organization_user" {
#   realm_id = keycloak_realm.realm.id
#   name     = "Organization.User"

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# # resource "keycloak_role" "organization_viewer" {
# #   realm_id = keycloak_realm.realm.id
# #   name     = "Organization.Viewer"

# #   depends_on = [
# #     keycloak_realm.realm,
# #   ]
# # }


# resource "keycloak_openid_client" "cosmotech_api" {
#   enabled                  = true
#   realm_id                 = keycloak_realm.realm.id
#   client_id                = local.client_name_api
#   name                     = local.client_name_api
#   access_type              = "CONFIDENTIAL"
#   standard_flow_enabled    = true
#   service_accounts_enabled = true
#   full_scope_allowed       = true

#   valid_redirect_uris = [
#     "https://${var.cluster_domain}/*",
#   ]

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }


# resource "keycloak_openid_client" "babylon" {
#   enabled                  = true
#   realm_id                 = keycloak_realm.realm.id
#   client_id                = local.client_name_babylon
#   name                     = local.client_name_babylon
#   access_type              = "CONFIDENTIAL"
#   standard_flow_enabled    = true
#   service_accounts_enabled = true
#   full_scope_allowed       = true

#   valid_redirect_uris = [
#     "https://${var.cluster_domain}/*",
#   ]

#   depends_on = [
#     keycloak_realm.realm,
#   ]
# }

# # Secret that will be used directly from Babylon
# resource "kubernetes_secret" "babylon" {
#   metadata {
#     name      = "keycloak-babylon"
#     namespace = var.tenant
#   }

#   data = {
#     "client_id" : keycloak_openid_client.babylon.client_id,
#     "client_secret" : keycloak_openid_client.babylon.client_secret,
#     "url" : "${keycloak_openid_client.babylon.client_id}/realms/${var.tenant}/protocol/openid-connect/token",
#     # "grant_type" : "client_credentials",
#     # "scope" : "openid",
#   }

#   type = "Opaque"

#   depends_on = [
#     keycloak_openid_client.babylon,
#   ]
# }




# # resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
# #   realm_id  = keycloak_realm.realm.id
# #   client_id = keycloak_openid_client.cosmotech_api.id

# #   default_scopes = [
# #     "web-origins",
# #     "acr",
# #     "roles",
# #     "profile",
# #     "basic",
# #     "email"
# #   ]
# # }

# # resource "keycloak_openid_client_optional_scopes" "client_optional_scopes" {
# #   realm_id  = keycloak_realm.realm.id
# #   client_id = keycloak_openid_client.cosmotech_api.id

# #   optional_scopes = [
# #     "address",
# #     "phone",
# #     "offline_access",
# #     "microprofile-jwt",
# #   ]
# # }




# # create web client
# resource "keycloak_openid_client" "cosmotech-web-client" {
#   realm_id  = keycloak_realm.realm.id
#   client_id = "cosmotech-web-client"

#   name    = "cosmotech-web-client"
#   enabled = true

#   standard_flow_enabled = true
#   access_type           = "CONFIDENTIAL"
#   valid_redirect_uris = [
#     "https://${var.cluster_domain}/${var.tenant}/v5/swagger-ui/oauth2-redirect.html",
#     "/*"
#   ]

#   login_theme = "keycloak"

#   # Added parameters
#   root_url           = "https://${var.cluster_domain}"
#   base_url           = "/${var.tenant}/v5/"
#   web_origins        = ["+"]
#   full_scope_allowed = true
# }

# resource "keycloak_generic_protocol_mapper" "branch_code_mapper" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech-web-client.id
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
#   client_id       = keycloak_openid_client.cosmotech-web-client.id
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

# resource "keycloak_generic_protocol_mapper" "realm_roles_mapper" {
#   realm_id        = keycloak_realm.realm.id
#   client_id       = keycloak_openid_client.cosmotech-web-client.id
#   name            = "realm roles"
#   protocol        = "openid-connect"
#   protocol_mapper = "oidc-usermodel-realm-role-mapper"
#   config = {
#     "id.token.claim" : "true",
#     "access.token.claim" : "true",
#     "claim.name" : "customRoles",
#     "jsonType.label" : "String",
#     "multivalued" : "true",
#     "userinfo.token.claim" : "true",
#     "introspection.token.claim" : "true"
#   }
# }

# resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
#   realm_id  = keycloak_realm.realm.id
#   client_id = keycloak_openid_client.cosmotech-web-client.id

#   default_scopes = [
#     "web-origins",
#     "acr",
#     "roles",
#     "profile",
#     "basic",
#     "email"
#   ]
# }

# resource "keycloak_openid_client_optional_scopes" "client_optional_scopes" {
#   realm_id  = keycloak_realm.realm.id
#   client_id = keycloak_openid_client.cosmotech-web-client.id

#   optional_scopes = [
#     "address",
#     "phone",
#     "offline_access",
#     "microprofile-jwt",
#   ]
# }









data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = "keycloak-temp"
    name      = "keycloak"
  }
}


# create web client
resource "keycloak_openid_client" "cosmotech-web-client" {
  realm_id  = keycloak_realm.realm.id
  client_id = "cosmotech-web-client"

  name    = "cosmotech-web-client"
  enabled = true

  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://${var.cluster_domain}/${var.tenant}/v5/swagger-ui/oauth2-redirect.html",
    "/*"
  ]

  login_theme = "keycloak"

  # Added parameters
  root_url           = "https://${var.cluster_domain}"
  base_url           = "/${var.tenant}/v5/"
  web_origins        = ["+"]
  full_scope_allowed = true
}

resource "keycloak_generic_protocol_mapper" "branch_code_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech-web-client.id
  name            = "BranchCodeMapper"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-attribute-mapper"
  config = {
    "aggregate.attrs" : "false",
    "multivalued" : "false",
    "userinfo.token.claim" : "true",
    "user.attribute" : "branch",
    "id.token.claim" : "false",
    "access.token.claim" : "true",
    "claim.name" : "branch",
    "jsonType.label" : "String",
    "introspection.token.claim" : "true"
  }
}

resource "keycloak_generic_protocol_mapper" "email_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech-web-client.id
  name            = "email"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-property-mapper"
  config = {
    "user.attribute" : "email",
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "email",
    "jsonType.label" : "String",
    "userinfo.token.claim" : "true",
    "introspection.token.claim" : "true"
  }
}

resource "keycloak_generic_protocol_mapper" "realm_roles_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech-web-client.id
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

resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.cosmotech-web-client.id

  default_scopes = [
    "web-origins",
    "acr",
    "roles",
    "profile",
    "basic",
    "email"
  ]
}

resource "keycloak_openid_client_optional_scopes" "client_optional_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.cosmotech-web-client.id

  optional_scopes = [
    "address",
    "phone",
    "offline_access",
    "microprofile-jwt",
  ]
}

# create roles
resource "keycloak_role" "platform_admin_role" {
  realm_id = keycloak_realm.realm.id
  name     = "Platform.Admin"
}

resource "keycloak_role" "organization_user_role" {
  realm_id = keycloak_realm.realm.id
  name     = "Organization.User"
}

# create auto linker
resource "keycloak_authentication_flow" "flow" {
  realm_id    = keycloak_realm.realm.id
  alias       = "auto link user"
  provider_id = "basic-flow"
}

resource "keycloak_authentication_execution" "execution1" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow.alias
  authenticator     = "idp-create-user-if-unique"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_execution" "execution2" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.flow.alias
  authenticator     = "idp-auto-link"
  requirement       = "ALTERNATIVE"

  depends_on = [keycloak_authentication_execution.execution1]
}

# create user
resource "keycloak_user" "user_with_initial_password" {
  realm_id = keycloak_realm.realm.id
  username = "default-tenant-user"
  enabled  = true

  lifecycle {
    ignore_changes = [
      email,
      first_name,
      last_name,
    ]
  }
}
# automation client
resource "keycloak_openid_client" "automation-client" {
  # count                    = var.deploy_automation_client ? 1 : 0

  realm_id                 = keycloak_realm.realm.id
  client_id                = "automation-client"
  name                     = "automation-client"
  enabled                  = true
  standard_flow_enabled    = false
  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
  login_theme              = "keycloak"
  root_url                 = "https://${var.cluster_domain}"
  full_scope_allowed       = true
}

resource "keycloak_generic_protocol_mapper" "automation_realm_roles_mapper" {
  # count           = var.deploy_automation_client ? 1 : 0

  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.automation-client.id
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

resource "keycloak_openid_client_service_account_realm_role" "automation_client_service_account_role" {
  # count                   = var.deploy_automation_client ? 1 : 0

  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.automation-client.service_account_user_id
  role                    = keycloak_role.platform_admin_role.name
}

# cosmotech api client
resource "keycloak_openid_client" "cosmotech-api-client" {
  realm_id                 = keycloak_realm.realm.id
  client_id                = "cosmotech-api-client"
  name                     = "cosmotech-api-client"
  enabled                  = true
  standard_flow_enabled    = false
  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = true
  login_theme              = "keycloak"
  root_url                 = "https://${var.cluster_domain}"
  full_scope_allowed       = true
}

resource "keycloak_generic_protocol_mapper" "api_realm_roles_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_id       = keycloak_openid_client.cosmotech-api-client.id
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

resource "keycloak_openid_client_service_account_realm_role" "client_service_account_role" {
  # count                   = var.keycloak_add_identity_provider_azure ? 1 : 0
  realm_id                = keycloak_realm.realm.id
  service_account_user_id = keycloak_openid_client.cosmotech-api-client.service_account_user_id
  role                    = keycloak_role.platform_admin_role.name
  depends_on              = [keycloak_openid_client.cosmotech-api-client]
}


# data "kubernetes_secret" "keycloak_app_secret" {
#   count = var.keycloak_add_identity_provider_azure ? 1 : 0
#   metadata {
#     name      = "keycloak-client-secret"
#     namespace = var.tenant
#   }
# }

# resource "keycloak_oidc_identity_provider" "realm_identity_provider" {
#   count             = var.keycloak_add_identity_provider_azure ? 1 : 0
#   realm             = keycloak_realm.realm.id
#   alias             = "azure-oidc"
#   display_name      = "Cosmo Tech Entra ID"
#   authorization_url = "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize"
#   token_url         = "https://login.microsoftonline.com/organizations/oauth2/v2.0/token"
#   logout_url        = "https://login.microsoftonline.com/organizations/oauth2/v2.0/logout"
#   user_info_url     = "https://graph.microsoft.com/oidc/userinfo"
#   issuer            = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
#   jwks_url          = "https://login.microsoftonline.com/organizations/discovery/v2.0/keys"
#   client_id         = var.keycloak_add_identity_provider_azure ? data.kubernetes_secret.keycloak_app_secret.0.data.client_id : ""
#   client_secret     = var.keycloak_add_identity_provider_azure ? data.kubernetes_secret.keycloak_app_secret.0.data.password : ""
#   sync_mode         = "FORCE"
#   default_scopes    = "openid profile email"

#   trust_email        = true
#   validate_signature = true

#   extra_config = {
#     "clientAuthMethod" = "client_secret_post"
#   }

#   depends_on = [data.kubernetes_secret.keycloak_app_secret]
# }

# resource "keycloak_attribute_to_role_identity_provider_mapper" "oidc_platform_admin" {
#   count                   = var.keycloak_add_identity_provider_azure ? 1 : 0
#   realm                   = keycloak_realm.realm.id
#   name                    = "Platform Admin"
#   identity_provider_alias = keycloak_oidc_identity_provider.realm_identity_provider.0.alias
#   role                    = "Platform.Admin"
#   claim_name              = "roles"
#   claim_value             = "Platform.Admin"
#   # extra_config with syncMode is required in Keycloak 10+
#   extra_config = {
#     syncMode = "FORCE"
#   }
#   depends_on = [keycloak_oidc_identity_provider.realm_identity_provider]
# }

# resource "keycloak_attribute_to_role_identity_provider_mapper" "oidc_organization_user" {
#   count                   = var.keycloak_add_identity_provider_azure ? 1 : 0
#   realm                   = keycloak_realm.realm.id
#   name                    = "Organization User"
#   identity_provider_alias = keycloak_oidc_identity_provider.realm_identity_provider.0.alias
#   role                    = "Organization.User"
#   claim_name              = "roles"
#   claim_value             = "Organization.User"
#   # extra_config with syncMode is required in Keycloak 10+
#   extra_config = {
#     syncMode = "FORCE"
#   }
#   depends_on = [keycloak_oidc_identity_provider.realm_identity_provider]
# }