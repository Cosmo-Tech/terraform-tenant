locals {
  initdatabase_template = templatefile("${path.module}/templates/initdb_internal.yaml", local.initdatabase_values)
  initdatabase_values = {
    NAMESPACE             = var.namespace
    REGISTRY              = var.registry
    REGISTRY_AUTH_SECRET  = var.registry_auth_secret
    POSTGRESQL_IMAGE_NAME = var.internal_postgresql_image_name
    POSTGRESQL_IMAGE_TAG  = var.internal_postgresql_image_tag
    DB_HOST               = var.database_host
    DB_PORT               = var.database_port
    DB_POSTGRES_USERNAME  = var.database_username
    DB_POSTGRES_PASSWORD  = var.database_password
    DB_NAME               = var.database_name
    DB_ADMIN_USERNAME     = local.database_admin_username
    DB_WRITER_USERNAME    = local.database_writer_username
    DB_READER_USERNAME    = local.database_reader_username
    DB_ADMIN_PASSWORD     = local.database_admin_password
    DB_WRITER_PASSWORD    = local.database_writer_password
    DB_READER_PASSWORD    = local.database_reader_password
  }
}


resource "kubectl_manifest" "initdb" {
  count = var.use_external_postgresql ? 0 : 1

  yaml_body = local.initdatabase_template

  lifecycle {
    replace_triggered_by = [
      terraform_data.initdatabase_trigger,
    ]
  }
}

resource "terraform_data" "initdatabase_trigger" {
  count = var.use_external_postgresql ? 0 : 1

  input = {
    values = local.initdatabase_template
  }
}
