# Roles
resource "postgresql_role" "admin" {
  count = var.use_external_postgresql ? 1 : 0

  name            = local.database_admin_username
  password        = local.database_admin_password
  login           = true
  create_database = true
}


# Database
resource "postgresql_database" "cosmotech" {
  count = var.use_external_postgresql ? 1 : 0

  name              = var.database_name
  owner             = postgresql_role.admin[0].name
  connection_limit  = -1
  allow_connections = true

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    postgresql_role.admin,
  ]
}


# Schema
resource "postgresql_schema" "schema" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.database_schema_name
  database = postgresql_database.cosmotech[0].name

  owner = postgresql_role.admin[0].name

  depends_on = [
    postgresql_database.cosmotech,
  ]
}
