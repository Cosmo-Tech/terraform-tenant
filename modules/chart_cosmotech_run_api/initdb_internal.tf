locals {
  initdb_template = templatefile("${path.module}/templates/initdb_internal.yaml", local.initdb_values)
  initdb_values = {
    NAMESPACE                    = var.namespace
    REGISTRY                     = var.registry
    REGISTRY_AUTH_SECRET         = var.registry_auth_secret
    COSMOTECH_RUN_API_IMAGE_NAME = var.cosmotech_run_api_image_name
    COSMOTECH_RUN_API_IMAGE_TAG  = var.cosmotech_run_api_image_tag
    POSTGRESQL_IMAGE_NAME        = var.internal_postgresql_image_name
    POSTGRESQL_IMAGE_TAG         = var.internal_postgresql_image_tag
    DB_HOST                      = local.db_target.db_host
    DB_PORT                      = local.db_target.db_port
    DB_POSTGRES_PASSWORD         = local.db_target.db_password
    DB_NAME                      = local.db_target.db_name
    DB_ADMIN_USERNAME            = local.db_target.admin_username
    DB_WRITER_USERNAME           = local.db_target.writer_username
    DB_READER_USERNAME           = local.db_target.reader_username
    DB_ADMIN_PASSWORD            = local.db_target.admin_password
    DB_WRITER_PASSWORD           = local.db_target.writer_password
    DB_READER_PASSWORD           = local.db_target.reader_password
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
