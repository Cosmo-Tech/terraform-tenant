locals {
  chart_values = {
    "POSTGRESQL_INITDB_SECRET"      = "var.postgresql_initdb_secret_name"
    "MONITORING_NAMESPACE"          = "var.monitoring_namespace"
    "POSTGRESQL_SECRET_NAME"        = "var.postgresql_secret_name"
    "POSTGRESQL_PASSWORD"           = "data.kubernetes_secret.postgres_config.data.postgres-password"
    "POSTGRESQL_DATABASE"           = "data.kubernetes_secret.postgres_config.data.database-name"
    "PERSISTENCE_SIZE"              = "var.persistence_size"
    "POSTGRESQL_EXISTING_PVC_NAME"  = "var.postgresql_existing_pvc_name"
    "POSTGRESQL_STORAGE_CLASS_NAME" = "var.postgresql_pvc_storage_class_name"
  }
  # seaweedfs_username        = var.seaweedfs_username
  # seaweedfs_password_secret = "${var.postgresql_secret_name}-seaweedfs"
  # seaweedfs_database        = var.seaweedfs_database

}


resource "helm_release" "postgresql" {
  namespace    = var.tenant
  name         = "postgresql-${var.tenant}"
  repository   = "https://charts.bitnami.com/bitnami"
  chart        = "postgresql"
  version      = "11.6.12"
  reset_values = true
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]


  # replace = true

  depends_on = [
    var.tenant,
    var.pvc,
  ]
}
