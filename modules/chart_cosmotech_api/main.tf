locals {
  chart_values_file = templatefile("${path.module}/values.yaml", local.chart_values)
  chart_values = {
    CLUSTER_DOMAIN             = var.cluster_domain
    NAMESPACE                  = var.tenant
    NAMESPACE_MONITORING       = "monitoring"
    KEYCLOAK_CLIENT_ID         = var.keycloak_client_id
    KEYCLOAK_CLIENT_PASSWORD   = var.keycloak_client_secret
    REDIS_PASSWORD             = data.kubernetes_secret.redis.data["redis-password"]
    REDIS_PORT                 = "6379"
    S3_ENDPOINT                = "http://${var.s3_host}:${var.s3_port}"
    S3_BUCKET                  = var.s3_bucket
    S3_USERNAME                = data.kubernetes_secret.s3.data["${var.s3_secret_key_username}"]
    S3_PASSWORD                = data.kubernetes_secret.s3.data["${var.s3_secret_key_password}"]
    POSTGRESQL_DATABASE_HOST   = local.db_target.host
    POSTGRESQL_DATABASE_NAME   = local.db_target.database
    POSTGRESQL_ADMIN_USERNAME  = local.db_target.host.admin_username
    POSTGRESQL_WRITER_USERNAME = local.db_target.host.writer_username
    POSTGRESQL_READER_USERNAME = local.db_target.host.reader_username
    POSTGRESQL_ADMIN_PASSWORD  = local.db_admin_password
    POSTGRESQL_WRITER_PASSWORD = local.db_writer_password
    POSTGRESQL_READER_PASSWORD = local.db_reader_password
    REGISTRY_URL               = var.cluster_domain
    REGISTRY_USERNAME          = data.kubernetes_secret.registry.data["username"]
    REGISTRY_PASSWORD          = data.kubernetes_secret.registry.data["password"]
  }

  db_admin_username  = "cosmotech_api_admin"
  db_writer_username = "cosmotech_api_writer"
  db_reader_username = "cosmotech_api_reader"
  db_admin_password  = random_password.password[4].result
  db_writer_password = random_password.password[5].result
  db_reader_password = random_password.password[6].result

  db_role_prefix = replace(var.tenant, "-", "_")

  db_target = var.use_external_postgresql ? {
    ## External
    db_host         = var.external_postgresql_host
    db_port         = var.external_postgresql_port
    db_username     = var.external_postgresql_username
    db_password     = var.external_postgresql_password
    db_name         = var.tenant
    admin_username  = "${local.db_role_prefix}_${local.db_admin_username}"
    writer_username = "${local.db_role_prefix}_${local.db_writer_username}"
    reader_username = "${local.db_role_prefix}_${local.db_reader_username}"
    } : {
    ## Internal
    db_host = "${helm_release.postgresql.name}.${helm_release.postgresql.namespace}.svc.cluster.local"
    db_port = "5432"
    # db_username     = data.kubernetes_secret.postgresql-config.data["username"]
    db_password     = data.kubernetes_secret.postgresql-config.data["password"]
    db_name         = "cosmotech"
    admin_username  = local.db_admin_username
    writer_username = local.db_writer_username
    reader_username = local.db_reader_username
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


data "kubernetes_secret" "postgresql-config" {
  metadata {
    namespace = var.tenant
    name      = "postgresql-config"
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


resource "helm_release" "cosmotech_api" {
  namespace  = var.tenant
  name       = "${var.chart_release}-${var.tenant}"
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


# Specific secret containing Cosmo Tech API database informations
resource "kubernetes_secret" "postgresql-cosmotechapi" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-cosmotechapi"
  }

  data = {
    "database-host"   = local.db_target.host
    "database-port"   = local.db_target.port
    "database-name"   = local.db_target.database
    "admin-username"  = local.db_target.admin_username
    "admin-password"  = local.db_target.admin_password
    "writer-username" = local.db_target.writer_username
    "writer-password" = local.db_target.writer_password
    "reader-username" = local.db_target.reader_username
    "reader-password" = local.db_target.reader_password
  }
}