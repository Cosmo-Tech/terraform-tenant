locals {

}



resource "helm_release" "cosmotech_api" {


  namespace    = var.tenant_name

  name       = "argo-workflows"
  repository = "https://charts.bitnami.com/bitnami"
  chart       = "argo-workflows"
  version     = "9.1.6"

  reset_values = true

  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  depends_on = [
    var.tenant_name,
  ]
}


data "kubernetes_secret" "network_client_password" {
  metadata {
    name      = "network-client-secret"
    namespace = "default"
  }
}