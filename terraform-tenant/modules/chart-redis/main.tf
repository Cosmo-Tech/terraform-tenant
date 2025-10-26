locals {
  chart_values = {
    "PERSISTENCE_MASTER_SIZE"           = var.size_master
    "PERSISTENCE_MASTER_PVC"            = var.pvc_master
    "PERSISTENCE_MASTER_STORAGE_CLASS"  = var.pvc_master_storage_class
    "PERSISTENCE_REPLICA_SIZE"          = var.size_replica
    "PERSISTENCE_REPLICA_PVC"           = var.pvc_replica
    "PERSISTENCE_REPLICA_STORAGE_CLASS" = var.pvc_replica_storage_class
    "REDIS_SECRET"                      = kubernetes_secret.secret.metadata[0].name
    "REDIS_PASSWORD"                    = kubernetes_secret.secret.data.password
    "REDIS_VERSION_COSMOTECH"           = "1.0.13"
  }

}


resource "random_password" "password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


resource "kubernetes_secret" "secret" {
  metadata {
    namespace = var.tenant
    name      = "${var.release}-config"
  }

  data = {
    "password" = random_password.password.result
  }

  type = "Opaque"
}



resource "helm_release" "redis" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  # version    = "19.6.2"
  version    = "23.2.1"
  # version    = "17.8.0"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
    var.pvc_master,
    var.pvc_replica,
    kubernetes_secret.secret,
  ]
}
