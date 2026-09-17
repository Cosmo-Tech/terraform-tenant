# 1. Create the schema with the admin as owner
resource "postgresql_schema" "schema" {
  count = var.use_external_postgresql ? 1 : 0

  name     = local.database_schema_name
  database = var.database_name
  owner    = var.database_admin_username
}

# 2. Full privileges on the schema for the Admin
resource "postgresql_grant" "schema_admin" {
  count = var.use_external_postgresql ? 1 : 0

  database    = var.database_name
  role        = var.database_admin_username
  schema      = postgresql_schema.schema[0].name
  object_type = "schema"
  privileges  = ["ALL"]
}

# 3. Full privileges on the schema for the application user (if separate)
resource "postgresql_grant" "schema_user" {
  count = (var.use_external_postgresql && var.database_username != null && var.database_username != var.database_admin_username) ? 1 : 0

  database    = var.database_name
  role        = var.database_username
  schema      = postgresql_schema.schema[0].name
  object_type = "schema"
  privileges  = ["ALL"]
}

# 4. Privileges on existing tables (Admin)
resource "postgresql_grant" "tables_admin" {
  count = var.use_external_postgresql ? 1 : 0

  database    = var.database_name
  role        = var.database_admin_username
  schema      = postgresql_schema.schema[0].name
  object_type = "table"
  privileges  = ["ALL"]
}

# 5. Default privileges on future tables
resource "postgresql_default_privileges" "tables_default" {
  count = var.use_external_postgresql ? 1 : 0

  database    = var.database_name
  role        = var.database_admin_username
  schema      = postgresql_schema.schema[0].name
  owner       = var.database_admin_username
  object_type = "table"
  privileges  = ["ALL"]
}

# 6. Default privileges on sequences
resource "postgresql_default_privileges" "sequences_default" {
  count = var.use_external_postgresql ? 1 : 0

  database    = var.database_name
  role        = var.database_admin_username
  schema      = postgresql_schema.schema[0].name
  owner       = var.database_admin_username
  object_type = "sequence"
  privileges  = ["ALL"]
}