locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    SERVICE_ACCOUNT            = var.chart_release
    DATABASE_HOST              = var.database_host
    DATABASE_PORT              = var.database_port
    DATABASE_NAME              = var.database_name
    DATABASE_USER              = var.database_user
    DATABASE_SECRET            = var.database_secret
    S3_ENDPOINT                = "${var.s3_host}:${var.s3_port}"
    S3_BUCKET                  = var.s3_bucket
    S3_SECRET                  = var.s3_secret
    S3_SECRET_KEY_USERNAME     = var.s3_secret_key_username
    S3_SECRET_KEY_PASSWORD     = var.s3_secret_key_password
    IMAGE_REGISTRY             = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET = var.image_registry_auth_secret
  }
}

resource "random_password" "password" {
  count = 10

  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}

resource "helm_release" "argo" {
  namespace  = var.tenant
  name       = var.chart_release
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_tag

  values = [
    local.chart_values_file
  ]

  force_update  = true
  recreate_pods = true
  # replace       = true

  lifecycle {
    replace_triggered_by = [
      terraform_data.helm_release_trigger,
    ]
  }

  depends_on = [
    var.tenant,
  ]
}

resource "terraform_data" "helm_release_trigger" {
  input = {
    version      = var.chart_tag
    values       = local.chart_values_file
    values_sha1  = sha1(local.chart_values_file)
    helm_release = data.kubernetes_resources.helm_release_secret
  }
}

data "kubernetes_resources" "helm_release_secret" {
  api_version    = "v1"
  kind           = "Secret"
  label_selector = "owner=helm,name=${var.chart_release}"
}
