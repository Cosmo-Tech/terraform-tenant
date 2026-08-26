terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}


provider "postgresql" {
  host            = var.external_postgresql_host
  port            = var.external_postgresql_port
  username        = var.external_postgresql_admin_username
  password        = var.external_postgresql_admin_password
  sslmode         = "require"
  connect_timeout = 15
}


# Roles
resource "postgresql_role" "admin" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.db_admin_username
  password = var.postgresql_admin_password
  login    = true
  # create_database = true
}

resource "postgresql_role" "writer" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.db_writer_username
  password = var.postgresql_writer_password
  login    = true
}

resource "postgresql_role" "reader" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.reader_username
  password = var.postgresql_reader_password
  login    = true
}


# Role grants: admin inherits writer & reader privileges
resource "postgresql_grant_role" "admin_writer" {
  count = var.use_external_postgresql ? 1 : 0

  role       = postgresql_role.admin.name
  grant_role = postgresql_role.writer.name
}

resource "postgresql_grant_role" "admin_reader" {
  count = var.use_external_postgresql ? 1 : 0

  role       = postgresql_role.admin.name
  grant_role = postgresql_role.reader.name
}


# Database
resource "postgresql_database" "tenant_cosmotech_api" {
  count = var.use_external_postgresql ? 1 : 0

  name              = local.db_name
  owner             = postgresql_role.admin.name
  connection_limit  = -1
  allow_connections = true

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
  database = postgresql_database.tenant_cosmotech_api.name

  owner = postgresql_role.writer.name

  depends_on = [
    postgresql_database.tenant,
  ]
}

resource "postgresql_grant" "reader_schema_usage" {
  count = var.use_external_postgresql ? 1 : 0

  database    = postgresql_database.tenant_cosmotech_api.name
  role        = postgresql_role.reader.name
  schema      = postgresql_schema.inputs.name
  object_type = "schema"
  privileges  = ["USAGE"]

  depends_on = [
    postgresql_schema.inputs,
  ]
}

resource "postgresql_default_privileges" "reader_select_tables" {
  count = var.use_external_postgresql ? 1 : 0

  database    = postgresql_database.tenant_cosmotech_api.name
  role        = postgresql_role.reader.name
  owner       = postgresql_role.writer.name
  schema      = postgresql_schema.inputs.name
  object_type = "table"
  privileges  = ["SELECT"]

  depends_on = [
    postgresql_schema.inputs,
  ]
}
