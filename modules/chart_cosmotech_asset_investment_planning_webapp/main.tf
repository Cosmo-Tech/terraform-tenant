locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    CLUSTER_DOMAIN             = var.cluster_domain
    NAMESPACE                  = var.tenant
    IMAGE_REGISTRY             = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET = var.image_registry_auth_secret
    IMAGE_REPOSITORY           = var.image_repository
    IMAGE_TAG                  = var.image_tag
    KEYCLOAK_CLIENT_ID         = var.keycloak_client_id
  }
}


resource "helm_release" "cosmotech_asset_investment_planning_webapp" {
  namespace  = var.tenant
  name       = var.chart_release
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_tag

  values = [
    local.chart_values_file
  ]

  force_update  = true
  recreate_pods = true
  # replace       = true

  lifecycle {
    replace_triggered_by = [
      terraform_data.helm_release_trigger,
    ]
  }

  depends_on = [
    var.tenant,
  ]
}

resource "terraform_data" "helm_release_trigger" {
  input = {
    version      = var.chart_tag
    values       = local.chart_values_file
    values_sha1  = sha1(local.chart_values_file)
    helm_release = data.kubernetes_resources.helm_release_secret
  }
}

data "kubernetes_resources" "helm_release_secret" {
  api_version    = "v1"
  kind           = "Secret"
  label_selector = "owner=helm,name=${var.chart_release}"
}
