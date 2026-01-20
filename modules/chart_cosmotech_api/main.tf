locals {
  chart_values = {
    "CLUSTER_DOMAIN"             = var.cluster_domain
    "NAMESPACE"                  = var.tenant
    "NAMESPACE_MONITORING"       = "monitoring"
    "KEYCLOAK_CLIENT_ID"         = var.keycloak_client_id
    "KEYCLOAK_CLIENT_PASSWORD"   = var.keycloak_client_secret
    "REDIS_PASSWORD"             = data.kubernetes_secret.redis.data["redis-password"]
    "REDIS_PORT"                 = "6379"
    "S3_ENDPOINT"                = "http://${var.s3_host}:${var.s3_port}"
    "S3_BUCKET"                  = var.s3_bucket
    "S3_USERNAME"                = data.kubernetes_secret.s3.data["${var.s3_secret_key_username}"]
    "S3_PASSWORD"                = data.kubernetes_secret.s3.data["${var.s3_secret_key_password}"]
    "POSTGRESQL_DATABASE_HOST"   = var.postgresql_host
    "POSTGRESQL_DATABASE_NAME"   = var.postgresql_database
    "POSTGRESQL_ADMIN_USERNAME"  = var.postgresql_admin_username
    "POSTGRESQL_ADMIN_PASSWORD"  = var.postgresql_admin_password
    "POSTGRESQL_WRITER_USERNAME" = var.postgresql_writer_username
    "POSTGRESQL_WRITER_PASSWORD" = var.postgresql_writer_password
    "POSTGRESQL_READER_USERNAME" = var.postgresql_reader_username
    "POSTGRESQL_READER_PASSWORD" = var.postgresql_reader_password
    "REGISTRY_URL"               = var.cluster_domain
    "REGISTRY_USERNAME"          = data.kubernetes_secret.registry.data["username"]
    "REGISTRY_PASSWORD"          = data.kubernetes_secret.registry.data["password"]
  }
}


data "kubernetes_secret" "redis" {
  metadata {
    namespace = var.tenant
    name      = "redis"
  }
}


data "kubernetes_secret" "s3" {
  metadata {
    namespace = var.tenant
    name      = var.s3_secret
  }
}


data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = var.tenant
    name      = "keycloak-cosmotech-client-api"
  }
}


data "kubernetes_secret" "registry" {
  metadata {
    namespace = var.tenant
    name      = "harbor"
  }
}


resource "helm_release" "cosmotech_api" {
  namespace  = var.tenant
  name       = "${var.release}-${var.tenant}"
  repository = "https://cosmo-tech.github.io/helm-charts"
  chart      = "cosmotech-api"
  version    = "5.0.0-rc5"
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
