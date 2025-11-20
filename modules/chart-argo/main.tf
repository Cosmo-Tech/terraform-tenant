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


# resource "kubernetes_secret" "secret" {
#   metadata {
#     namespace = var.tenant
#     name      = "${var.release}-admin"
#   }

#   data = {
#     "password" = random_password.password[0].result
#   }

#   type = "Opaque"
# }





resource "helm_release" "argo" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "argo-workflows"
  version    = "13.0.6"
  # version    = "9.1.6"
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
