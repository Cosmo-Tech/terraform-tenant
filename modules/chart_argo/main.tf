locals {
  chart_values = {
    "SERVICE_ACCOUNT"        = var.release
    "DATABASE_HOST"          = var.database_host
    "DATABASE_PORT"          = var.database_port
    "DATABASE_NAME"          = var.database_name
    "DATABASE_USER"          = var.database_user
    "DATABASE_SECRET"        = var.database_secret
    "S3_ENDPOINT"            = "${var.s3_host}:${var.s3_port}"
    "S3_BUCKET"              = var.s3_bucket
    "S3_SECRET"              = var.s3_secret
    "S3_SECRET_KEY_USERNAME" = var.s3_secret_key_username
    "S3_SECRET_KEY_PASSWORD" = var.s3_secret_key_password
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
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "argo-workflows"
  # version    = "13.0.6" # This is the latest bitnamilegacy/argo-workflows, but it's installing argo-workflows 3.7.1 which has a bug when using "namespaced" argument (more info: https://github.com/argoproj/argo-workflows/issues/14806)
  version    = "13.0.0"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
  ]
}
