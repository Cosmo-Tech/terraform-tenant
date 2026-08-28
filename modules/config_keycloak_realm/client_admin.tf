resource "keycloak_openid_client" "cosmotech_admin" {
  enabled                      = true
  realm_id                     = keycloak_realm.realm.id
  client_id                    = local.cosmotech_admin
  name                         = local.cosmotech_admin
  access_type                  = local.access_type
  full_scope_allowed           = local.full_scope_allowed
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
  service_accounts_enabled     = true

  depends_on = [
    keycloak_realm.realm,
  ]
}

data "keycloak_openid_client" "realm_management" {
  realm_id  = keycloak_realm.realm.id
  client_id = "realm-management"
}

data "keycloak_role" "realm_management_view_users" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realm_management.id
  name      = "view-users"
}

data "keycloak_role" "realm_management_query_groups" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realm_management.id
  name      = "query-groups"
}

data "keycloak_role" "realm_management_manage_users" {
  realm_id  = keycloak_realm.realm.id
  client_id = data.keycloak_openid_client.realm_management.id
  name      = "manage-users"
}

resource "keycloak_openid_client_service_account_role" "cosmotech_admin_view_users" {
  realm_id                 = keycloak_realm.realm.id
  service_account_user_id  = keycloak_openid_client.cosmotech_admin.service_account_user_id
  client_id                = data.keycloak_openid_client.realm_management.id
  role                     = data.keycloak_role.realm_management_view_users.name
}

resource "keycloak_openid_client_service_account_role" "cosmotech_admin_query_groups" {
  realm_id                 = keycloak_realm.realm.id
  service_account_user_id  = keycloak_openid_client.cosmotech_admin.service_account_user_id
  client_id                = data.keycloak_openid_client.realm_management.id
  role                     = data.keycloak_role.realm_management_query_groups.name
}

resource "keycloak_openid_client_service_account_role" "cosmotech_admin_manage_users" {
  realm_id                 = keycloak_realm.realm.id
  service_account_user_id  = keycloak_openid_client.cosmotech_admin.service_account_user_id
  client_id                = data.keycloak_openid_client.realm_management.id
  role                     = data.keycloak_role.realm_management_manage_users.name
}


# Secret exposing the client credentials of cosmotech-client-admin
resource "kubernetes_secret" "cosmotech-client-admin-credentials" {
  metadata {
    name      = "cosmotech-client-admin-credentials"
    namespace = var.tenant
  }

  data = {
    "keycloak_client_id" : keycloak_openid_client.cosmotech_admin.client_id,
    "keycloak_client_secret" : keycloak_openid_client.cosmotech_admin.client_secret,
  }

  type = "Opaque"

  depends_on = [
    keycloak_openid_client.cosmotech_admin,
  ]
}
