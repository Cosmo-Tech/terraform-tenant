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

    "POSTGRESQL_DATABASE_HOST" = var.postgresql_host
    # "POSTGRESQL_DATABASE_NAME"   = var.postgresql_database
    "POSTGRESQL_READER_USERNAME" = var.postgresql_username_reader
    "POSTGRESQL_READER_PASSWORD" = var.postgresql_password_reader
    "POSTGRESQL_WRITER_USERNAME" = var.postgresql_username_writer
    "POSTGRESQL_WRITER_PASSWORD" = var.postgresql_password_writer
    "POSTGRESQL_ADMIN_USERNAME"  = var.postgresql_username_admin
    "POSTGRESQL_ADMIN_PASSWORD"  = var.postgresql_password_admin

    # "IDENTITY_PROVIDER" = jsonencode(local.api_identity_provider)

    "CLUSTER_DOMAIN"           = var.cluster_domain
    "KEYCLOAK_CLIENT_ID"       = local.keycloak_client_id
    "KEYCLOAK_CLIENT_PASSWORD" = local.keycloak_client_secret
  }


  keycloak_realm         = var.tenant
  keycloak_client_id     = "cosmotech-api-client"
  keycloak_client_secret = var.keycloak_password_client

  # api_identity_provider = {
  #   audience         = "account"
  #   code             = "keycloak"
  #   authorizationUrl = "https://${var.cluster_domain}/keycloak/realms/${local.realm}/protocol/openid-connect/auth"
  #   tokenUrl         = "https://${var.cluster_domain}/keycloak/realms/${local.realm}/protocol/openid-connect/token"
  #   defaultScopes = {
  #     openid = "OpenId Scope"
  #   }
  #   serverBaseUrl = "https://${var.cluster_domain}/keycloak"
  #   tls = {
  #     enabled = false
  #   }
  #   identity = {
  #     clientId     = local.keycloak_client_id
  #     clientSecret = local.keycloak_client_secret
  #     tenantId     = local.keycloak_realm
  #   }
  # }


  # api_identity_provider = merge(var.api_identity_provider, local.api_keycloak_identity)
  # api_identity_provider = {
  #   audience         = "account"
  #   code             = "keycloak"
  #   authorizationUrl = "https://warp.api.cosmotech.com/keycloak/realms/sphinx/protocol/openid-connect/auth"
  #   tokenUrl         = "https://warp.api.cosmotech.com/keycloak/realms/sphinx/protocol/openid-connect/token"
  #   defaultScopes = {
  #     openid = "OpenId Scope"
  #   }
  #   serverBaseUrl = "https://warp.api.cosmotech.com/keycloak"
  #   tls = {
  #     enabled = false
  #   }
  # }
  # api_keycloak_identity = {
  #   identity = {
  #     clientId     = var.keycloak_client_id
  #     clientSecret = var.keycloak_client_secret
  #     tenantId     = var.kubernetes_tenant_namespace
  #   }
  # }
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
