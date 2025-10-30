resource "keycloak_realm" "realm" {
  enabled                     = true
  realm                       = var.tenant
  access_code_lifespan        = "30m"
  default_signature_algorithm = "RS256"
}

resource "keycloak_role" "platform_admin" {
  realm_id = keycloak_realm.realm.id
  name     = "Platform.Admin"
}

resource "keycloak_role" "organization_user" {
  realm_id = keycloak_realm.realm.id
  name     = "Organization.User"
}


resource "keycloak_openid_client" "cosmotech_api_client" {
  enabled                  = true
  realm_id                 = keycloak_realm.realm.id
  client_id                = "cosmotech-api-client"
  name                     = "cosmotech-api-client"
  access_type              = "CONFIDENTIAL"
  standard_flow_enabled    = false
  service_accounts_enabled = true
  root_url                 = "https://${var.cluster_domain}"


  # valid_redirect_uris = [
  #     "http://localhost:8080/openid-callback"
  # ]

  # extra_config = {
  #     "key1" = "value1"
  #     "key2" = "value2"
  # }
}


