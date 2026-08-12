terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.27.0"
    }
  }
}

locals {
  # Clean tenant prefix: PostgreSQL identifiers can't contain dashes.
  clean_prefix = replace(var.tenant, "-", "_")

  admin_username  = "${local.clean_prefix}_cosmotech_api_admin"
  writer_username = "${local.clean_prefix}_cosmotech_api_writer"
  reader_username = "${local.clean_prefix}_cosmotech_api_reader"

  database_name = var.tenant
}

# Roles

resource "postgresql_role" "admin" {
  name      = local.admin_username
  login     = true
  password  = var.postgresql_admin_password
  create_db = true
  # Azure Flexible Server admin accounts are not real superusers, so
  # tenant roles created here can't be superusers either.
  superuser = false
}

resource "postgresql_role" "writer" {
  name     = local.writer_username
  login    = true
  password = var.postgresql_writer_password
}

resource "postgresql_role" "reader" {
  name     = local.reader_username
  login    = true
  password = var.postgresql_reader_password
}

# Role grants: admin inherits writer & reader privileges

resource "postgresql_grant_role" "admin_writer" {
  role       = postgresql_role.admin.name
  grant_role = postgresql_role.writer.name
}

resource "postgresql_grant_role" "admin_reader" {
  role       = postgresql_role.admin.name
  grant_role = postgresql_role.reader.name
}


# Database

resource "postgresql_database" "tenant" {
  name              = local.database_name
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
  name     = "inputs"
  database = postgresql_database.tenant.name

  owner = postgresql_role.writer.name

  depends_on = [
    postgresql_database.tenant,
  ]
}

resource "postgresql_grant" "reader_schema_usage" {
  database    = postgresql_database.tenant.name
  role        = postgresql_role.reader.name
  schema      = postgresql_schema.inputs.name
  object_type = "schema"
  privileges  = ["USAGE"]

  depends_on = [
    postgresql_schema.inputs,
  ]
}

resource "postgresql_default_privileges" "reader_select_tables" {
  database    = postgresql_database.tenant.name
  role        = postgresql_role.reader.name
  owner       = postgresql_role.writer.name
  schema      = postgresql_schema.inputs.name
  object_type = "table"
  privileges  = ["SELECT"]

  depends_on = [
    postgresql_schema.inputs,
  ]
}
