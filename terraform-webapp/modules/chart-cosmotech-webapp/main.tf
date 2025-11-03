locals {
  chart_values = {
    "CLUSTER_DOMAIN"  = var.cluster_domain
    "WEBAPP_NAME"     = var.webapp_name
    "NAMESPACE"       = var.tenant
    "ORGANIZATION_ID" = var.organization_id
  }
}


resource "kubernetes_config_map" "webapp" {
  metadata {
    namespace = var.tenant
    name      = "${var.webapp_name}-server-configmap-config"
  }

  data = {
    "AssetCopyMapping.json"      = templatefile("${path.module}/AssetCopyMapping.json", local.chart_values)
    "ContentSecurityPolicy.json" = templatefile("${path.module}/ContentSecurityPolicy.json", local.chart_values)
    "GlobalConfiguration.json"   = templatefile("${path.module}/GlobalConfiguration.json", local.chart_values)
  }
}


resource "helm_release" "webapp" {
  namespace  = var.tenant
  name       = var.webapp_name
  repository = "https://cosmo-tech.github.io/helm-charts"
  chart      = "cosmotech-business-webapp"
  version    = "0.2.1"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    kubernetes_config_map.webapp,
  ]
}
