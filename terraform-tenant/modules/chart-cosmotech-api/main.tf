locals {

}



resource "helm_release" "cosmotech_api" {


  namespace = var.tenant

  name       = "argo-workflows"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "argo-workflows"
  version    = "9.1.6"

  reset_values = true

  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  depends_on = [
    var.tenant,
  ]
}
