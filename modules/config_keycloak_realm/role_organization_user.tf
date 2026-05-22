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
