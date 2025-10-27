locals {
  chart_values = {
    "DATABASE_HOST" = var.database_host
    "DATABASE_PORT" = var.database_port
    "DATABASE_NAME" = var.database_name
    "DATABASE_USER" = var.database_user
    "DATABASE_SECRET" = var.database_secret
    "SERVICE_ACCOUNT" = var.release
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


# resource "kubernetes_secret" "secret" {
#   metadata {
#     namespace = var.tenant
#     name      = "${var.release}-admin"
#   }

#   data = {
#     "password" = random_password.password[0].result
#   }

#   type = "Opaque"
# }





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
  ]
}
