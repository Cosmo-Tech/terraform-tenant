locals {
  chart_values = {
    "PERSISTENCE_SIZE"          = var.size
    "PERSISTENCE_PVC"           = var.pvc
    "PERSISTENCE_STORAGE_CLASS" = var.pvc_storage_class
    "POSTGRESQL_SECRET_CONFIG"  = kubernetes_secret.postgresql-config.metadata[0].name
  }

  database_host = "${helm_release.postgresql.name}.${helm_release.postgresql.namespace}.svc.cluster.local"
  database_port = "5432"
}


# Just generate an amount of secured passwords
resource "random_password" "password" {
  count = 10

  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


# Main secret containing PostgreSQL informations
# The key "postgres-password" is a common value that most of charts uses by default
resource "kubernetes_secret" "postgresql-config" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-config"
  }

  data = {
    "postgres-password" = random_password.password[1].result
  }

  depends_on = [
    random_password.password,
  ]
}


# Specific secret containing SeadweedFS database informations
# SeaweedFS chart requires to have a "postgresql-password" key in its secret
resource "kubernetes_secret" "postgresql-seaweedfs" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-seaweedfs"
  }

  data = {
    "postgresql-database" = "seaweedfs"
    "postgresql-username" = "seaweedfs"
    "postgresql-password" = random_password.password[2].result
  }
}


# Specific secret containing Argo Workflows database informations
resource "kubernetes_secret" "postgresql-argo" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-argo"
  }

  data = {
    "database-name"     = "argo"
    "database-username" = "argo"
    "database-password" = random_password.password[3].result
  }
}


# Specific secret containing Cosmo Tech API database informations
resource "kubernetes_secret" "postgresql-cosmotechapi" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-cosmotechapi"
  }

  data = {
    "admin-username"  = "cosmotech_api_admin"
    "admin-password"  = random_password.password[4].result
    "reader-username" = "cosmotech_api_reader"
    "reader-password" = random_password.password[5].result
    "writer-username" = "cosmotech_api_writer"
    "writer-password" = random_password.password[6].result
    "database-name"   = "cosmotech"
  }
}


resource "helm_release" "postgresql" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "16.7.27"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
    var.pvc,
    kubernetes_secret.postgresql-config,
    kubernetes_secret.postgresql-seaweedfs,
    kubernetes_secret.postgresql-argo,
  ]
}
