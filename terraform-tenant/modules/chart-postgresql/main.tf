locals {
  chart_values = {
    "POSTGRESQL_SECRET_NAME" = kubernetes_secret.secret.metadata[0].name
    "PERSISTENCE_SIZE"          = var.size
    "PERSISTENCE_PVC"           = var.pvc
    "PERSISTENCE_STORAGE_CLASS" = var.pvc_storage_class
  }

}

resource "random_password" "password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  min_special = 5
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "cosmotech-postgresql"
    namespace = var.tenant
  }

  data = {
    # "cosmotech-api-admin-password" = random_password.password.result
    # "cosmotech-api-admin-username" = cosmotech_api_admin
    # "cosmotech-api-reader-password" = random_password.password.result
    # "cosmotech-api-reader-username" = cosmotech_api_reader
    # "cosmotech-api-writer-password" = random_password.password.result
    # "cosmotech-api-writer-username" = cosmotech_api_writer
    # "database-password" = random_password.password.result
    "postgres-password" = random_password.password.result
    # "postgres-username" = postgres
  }

  type = "Opaque"

  depends_on = [
    random_password.password,
  ]
}


resource "helm_release" "postgresql" {
  namespace    = var.tenant
  name         = "postgresql"
  repository   = "https://charts.bitnami.com/bitnami"
  chart        = "postgresql"
  version      = "18.1.1"
  reset_values = true
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]


  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
    var.pvc,
    kubernetes_secret.secret,
  ]
}
