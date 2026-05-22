resource "keycloak_role" "platform_admin" {
  realm_id = keycloak_realm.realm.id
  name     = "Platform.Admin"

  depends_on = [
    keycloak_realm.realm,
  ]
}

# The group platform_admin is placed under the group organization_user
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
