terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}


locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    NAMESPACE                    = var.namespace
    REGISTRY                     = var.registry
    REGISTRY_AUTH_SECRET         = var.registry_auth_secret
    COSMOTECH_RUN_API_IMAGE_NAME = var.cosmotech_run_api_image_name
    COSMOTECH_RUN_API_IMAGE_TAG  = var.cosmotech_run_api_image_tag
    NAME                         = var.chart_release
    CLUSTER_DOMAIN               = var.cluster_domain
    NAMESPACE_MONITORING         = "monitoring"
    KEYCLOAK_API_CLIENT_ID       = var.keycloak_api_client_id
    KEYCLOAK_API_CLIENT_SECRET   = var.keycloak_api_client_secret
    KEYCLOAK_ADMIN_CLIENT_ID     = var.keycloak_admin_client_id
    KEYCLOAK_ADMIN_CLIENT_SECRET = var.keycloak_admin_client_secret
    REDIS_PASSWORD               = data.kubernetes_secret.redis.data["redis-password"]
    REDIS_PORT                   = "6379"
    S3_ENDPOINT                  = "http://${var.s3_host}:${var.s3_port}"
    S3_BUCKET                    = var.s3_bucket
    S3_USERNAME                  = data.kubernetes_secret.s3.data[var.s3_secret_key_username]
    S3_PASSWORD                  = data.kubernetes_secret.s3.data[var.s3_secret_key_password]
    DB_HOST                      = var.database_host
    DB_NAME                      = var.database_name
    DB_ADMIN_USERNAME            = local.database_admin_username
    DB_ADMIN_PASSWORD            = local.database_admin_password
    DB_WRITER_USERNAME           = local.database_writer_username
    DB_WRITER_PASSWORD           = local.database_writer_password
    DB_READER_USERNAME           = local.database_reader_username
    DB_READER_PASSWORD           = local.database_reader_password
    SIMU_REGISTRY_URL            = var.cluster_domain
    SIMU_REGISTRY_USERNAME       = data.kubernetes_secret.registry.data["username"]
    SIMU_REGISTRY_PASSWORD       = data.kubernetes_secret.registry.data["password"]
  }
  chart_release_name = "${var.chart_release}-${var.namespace}"


  database_role_prefix         = replace(var.namespace, "-", "_")
  raw_database_admin_username  = "cosmotech_api_admin"
  raw_database_writer_username = "cosmotech_api_writer"
  raw_database_reader_username = "cosmotech_api_reader"

  database_admin_username  = var.use_external_postgresql ? "${local.database_role_prefix}_${local.raw_database_admin_username}" : local.raw_database_admin_username
  database_writer_username = var.use_external_postgresql ? "${local.database_role_prefix}_${local.raw_database_writer_username}" : local.raw_database_writer_username
  database_reader_username = var.use_external_postgresql ? "${local.database_role_prefix}_${local.raw_database_reader_username}" : local.raw_database_reader_username
  database_admin_password  = random_password.api_admin_password.result
  database_writer_password = random_password.api_writer_password.result
  database_reader_password = random_password.api_reader_password.result
}


data "kubernetes_secret" "redis" {
  metadata {
    namespace = var.namespace
    name      = "redis"
  }
}


data "kubernetes_secret" "s3" {
  metadata {
    namespace = var.namespace
    name      = var.s3_secret
  }
}


data "kubernetes_secret" "postgresql-config" {
  metadata {
    namespace = var.namespace
    name      = "postgresql-config"
  }
}


data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = var.namespace
    name      = "keycloak-cosmotech-client-api"
  }
}


data "kubernetes_secret" "registry" {
  metadata {
    namespace = var.namespace
    name      = "harbor"
  }
}


data "kubernetes_secret" "certificate" {
  metadata {
    name      = "letsencrypt-prod"
    namespace = "cert-manager"
  }
}


resource "kubernetes_secret" "api_cert" {
  metadata {
    name      = "letsencrypt-prod-${local.chart_values["NAMESPACE"]}"
    namespace = local.chart_values["NAMESPACE"]
  }

  type = data.kubernetes_secret.certificate.type

  data = data.kubernetes_secret.certificate.data
}


resource "helm_release" "cosmotech_run_api" {
  namespace  = var.namespace
  name       = local.chart_release_name
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
    var.namespace,
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


# Specific secret containing Cosmo Tech API database informations
resource "kubernetes_secret" "postgresql-cosmotechapi" {
  type = "Opaque"

  metadata {
    namespace = var.namespace
    name      = "postgresql-cosmotechapi"
  }

  data = {
    "database-host"   = var.database_host
    "database-port"   = var.database_port
    "database-name"   = var.database_name
    "admin-username"  = local.database_admin_username
    "admin-password"  = local.database_admin_password
    "writer-username" = local.database_writer_username
    "writer-password" = local.database_writer_password
    "reader-username" = local.database_reader_username
    "reader-password" = local.database_reader_password
  }
}


resource "random_password" "api_admin_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}

resource "random_password" "api_writer_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}

resource "random_password" "api_reader_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


# List all services to be able retrieving the service name of the cosmotech-run-api
data "kubernetes_resources" "services" {
  api_version = "v1"
  kind        = "Service"
  namespace   = var.namespace
  label_selector = "app.kubernetes.io/instance=${local.chart_release_name}"

  depends_on = [
    helm_release.cosmotech_run_api,
  ]
}
