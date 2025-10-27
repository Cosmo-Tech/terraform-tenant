locals {

  # ACR_LOGIN_PASSWORD
  # ACR_LOGIN_SERVER
  # ACR_LOGIN_USERNAME

  # API_VERSION
  # API_VERSION_PATH


  # COSMOTECH_API_DNS_NAME
  # COSMOTECH_API_INGRESS_ENABLED
  # IDENTITY_PROVIDER
  # MONITORING_NAMESPACE
  # POSTGRESQL_ADMIN_PASSWORD
  # POSTGRESQL_ADMIN_USERNAME
  # POSTGRESQL_DATABASE
  # POSTGRESQL_READER_PASSWORD
  # POSTGRESQL_READER_USERNAME
  # POSTGRESQL_WRITER_PASSWORD
  # POSTGRESQL_WRITER_USERNAME

  # S3_ACCESS_KEY_ID
  # S3_BUCKET_NAME
  # S3_ENDPOINT_URL
  # S3_SECRET_ACCESS_KEY
  # TLS_SECRET_NAME

  chart_values = {
    "NAMESPACE" = var.tenant

    "API_VERSION_PATH" = "v5"

    "REDIS_PASSWORD" = data.kubernetes_secret.redis.data["password"]
    "REDIS_PORT"     = "6379"

    "S3_ENDPOINT" = "${var.s3_host}:${var.s3_port}"
    "S3_BUCKET"   = var.s3_bucket
    "S3_USERNAME" = data.kubernetes_secret.s3.data["${var.s3_secret_key_username}"]
    "S3_PASSWORD" = data.kubernetes_secret.s3.data["${var.s3_secret_key_password}"]

    "POSTGRESQL_DATABASE_HOST"   = var.postgresql_host
    # "POSTGRESQL_DATABASE_NAME"   = var.postgresql_database
    "POSTGRESQL_READER_USERNAME" = var.postgresql_username_reader
    "POSTGRESQL_READER_PASSWORD" = var.postgresql_password_reader
    "POSTGRESQL_WRITER_USERNAME" = var.postgresql_username_writer
    "POSTGRESQL_WRITER_PASSWORD" = var.postgresql_password_writer
    "POSTGRESQL_ADMIN_USERNAME"  = var.postgresql_username_admin
    "POSTGRESQL_ADMIN_PASSWORD"  = var.postgresql_password_admin
  }
}


data "kubernetes_secret" "redis" {
  metadata {
    namespace = var.tenant
    name      = "redis-svcbind"
  }
}


data "kubernetes_secret" "s3" {
  metadata {
    namespace = var.tenant
    name      = var.s3_secret
  }
}


resource "helm_release" "cosmotech_api" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://cosmo-tech.github.io/helm-charts"
  chart      = "cosmotech-api"
  version    = "5.0.0-beta6"
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
