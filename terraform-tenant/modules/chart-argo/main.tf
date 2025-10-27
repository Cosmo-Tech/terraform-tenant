locals {
  chart_values = {
    "PERSISTENCE_SIZE"          = var.size
    "PERSISTENCE_PVC"           = var.pvc
    "PERSISTENCE_STORAGE_CLASS" = var.pvc_storage_class
    "RELEASE"                   = var.release
    "SECRET_CREDENTIALS"        = kubernetes_secret.credentials.metadata[0].name
    "SECRET_LOAD_DEFINITION"    = kubernetes_secret.load_definition.metadata[0].name
  }
}


resource "random_password" "password" {
  count = 10

  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


resource "kubernetes_secret" "admin" {
  metadata {
    namespace = var.tenant
    name      = "${var.release}-admin"
  }

  data = {
    "password" = random_password.password[0].result
  }

  type = "Opaque"
}





resource "helm_release" "argo" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "argo-workflows"
  version    = "13.0.6"
  # version    = "9.1.6"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
    var.pvc,
    kubernetes_secret.credentials,
  ]
}
