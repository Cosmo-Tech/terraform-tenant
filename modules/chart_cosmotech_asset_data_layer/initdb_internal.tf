locals {
  initdb_template = templatefile("${path.module}/templates/initdb_internal.yaml", local.initdb_values)
  initdb_values = {
    NAMESPACE             = var.namespace
    REGISTRY              = var.registry
    REGISTRY_AUTH_SECRET  = var.registry_auth_secret
    POSTGRESQL_IMAGE_NAME = var.internal_postgresql_image_name
    POSTGRESQL_IMAGE_TAG  = var.internal_postgresql_image_tag
    DB_HOST               = var.database_host
    DB_PORT               = var.database_port
    DB_NAME               = var.database_name
    DB_POSTGRES_USERNAME  = var.database_username
    DB_POSTGRES_PASSWORD  = var.database_password
    DB_ADMIN_USERNAME     = var.database_admin_username
    DB_ADMIN_PASSWORD     = var.database_admin_password
    DB_SCHEMA_NAME        = local.database_schema_name
  }
}


resource "kubectl_manifest" "initdb" {
  count = var.use_external_postgresql ? 0 : 1

  yaml_body = local.initdb_template

  lifecycle {
    replace_triggered_by = [
      terraform_data.initdb_trigger,
    ]
  }
}

resource "terraform_data" "initdb_trigger" {
  count = var.use_external_postgresql ? 0 : 1

  input = {
    values = local.initdb_template
  }
}
