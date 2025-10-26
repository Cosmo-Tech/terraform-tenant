locals {
  chart_values = {
    "PERSISTENCE_MASTER_SIZE"          = var.size_master
    "PERSISTENCE_MASTER_PVC"           = var.pvc_master
    "PERSISTENCE_MASTER_STORAGE_CLASS" = var.pvc_master_storage_class
    "PERSISTENCE_MASTER_ACCESS_MODES"  = var.pvc_master_access_modes
    "PERSISTENCE_VOLUME_SIZE"          = var.size_volume
    "PERSISTENCE_VOLUME_PVC"           = var.pvc_volume
    "PERSISTENCE_VOLUME_STORAGE_CLASS" = var.pvc_volume_storage_class
    "PERSISTENCE_VOLUME_ACCESS_MODES"  = var.pvc_volume_access_modes
    "DATABASE_HOST"                    = var.database_host
    "DATABASE_PORT"                    = var.database_port
    "DATABASE_NAME"                    = var.database_seaweedfs_name
    "DATABASE_USER"                    = var.database_seaweedfs_user
    "DATABASE_SECRET"                  = var.database_seaweedfs_secret
    "S3_INIT_BUCKETS"                  = ["argo-workflows", "cosmotech-api"]
    "FILER_ENDPOINT"                   = "http://${var.release}-filer.${var.tenant}.svc.cluster.local:8888"
  }

}


resource "helm_release" "seaweedfs" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "seaweedfs"
  version    = "6.0.1"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  # repository  = "oci://registry-1.docker.io/bitnamicharts"
  # repository  = "oci://registry-1.docker.io/bitnamilegacy"

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
    var.pvc_master,
    var.pvc_volume,
    var.database_seaweedfs_name,
    var.database_seaweedfs_secret,
  ]
}
