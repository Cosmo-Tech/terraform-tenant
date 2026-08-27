# Roles
resource "postgresql_role" "admin" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.db_target.admin_username
  password = local.db_target.admin_password
  login    = true
  # create_database = true
}

resource "postgresql_role" "writer" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.db_target.writer_username
  password = local.db_target.writer_password
  login    = true
}

resource "postgresql_role" "reader" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.db_target.reader_username
  password = local.db_target.reader_password
  login    = true
}


# Role grants: admin inherits writer & reader privileges
resource "postgresql_grant_role" "admin_writer" {
  count = var.use_external_postgresql ? 1 : 0

  role       = postgresql_role.admin[0].name
  grant_role = postgresql_role.writer[0].name
}

resource "postgresql_grant_role" "admin_reader" {
  count = var.use_external_postgresql ? 1 : 0

  role       = postgresql_role.admin[0].name
  grant_role = postgresql_role.reader[0].name
}


# Database
resource "postgresql_database" "tenant_cosmotech_api" {
  count = var.use_external_postgresql ? 1 : 0

  name              = local.db_target.db_name
  owner             = postgresql_role.admin[0].name
  connection_limit  = -1
  allow_connections = true

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    postgresql_role.admin,
    postgresql_role.writer,
    postgresql_role.reader,
  ]
}


# Schema & privileges (connect through the tenant database)
resource "postgresql_schema" "inputs" {
  count = var.use_external_postgresql ? 1 : 0

  name     = "inputs"
  database = postgresql_database.tenant_cosmotech_api[0].name

  owner = postgresql_role.writer[0].name

  depends_on = [
    postgresql_database.tenant_cosmotech_api,
  ]
}

resource "postgresql_grant" "reader_schema_usage" {
  count = var.use_external_postgresql ? 1 : 0

  database    = postgresql_database.tenant_cosmotech_api[0].name
  role        = postgresql_role.reader[0].name
  schema      = postgresql_schema.inputs[0].name
  object_type = "schema"
  privileges  = ["USAGE"]

  depends_on = [
    postgresql_schema.inputs,
  ]
}

resource "postgresql_default_privileges" "reader_select_tables" {
  count = var.use_external_postgresql ? 1 : 0

  database    = postgresql_database.tenant_cosmotech_api[0].name
  role        = postgresql_role.reader[0].name
  owner       = postgresql_role.writer[0].name
  schema      = postgresql_schema.inputs[0].name
  object_type = "table"
  privileges  = ["SELECT"]

  depends_on = [
    postgresql_schema.inputs,
  ]
}
