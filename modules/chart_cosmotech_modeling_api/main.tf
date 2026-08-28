locals {
  chart_values = templatefile("${path.module}/templates/values.yaml", local.chart_values_data)
  chart_values_data = {
    NAMESPACE              = var.tenant
    IMAGE_TAG              = var.image_tag
    IMAGE_PULL_SECRET      = var.image_registry_auth_secret
    PERSISTENCE_PVC        = var.pvc
    S3_ENDPOINT            = "http://${var.s3_host}:${var.s3_port}"
    S3_BUCKET              = var.s3_bucket
    S3_SECRET              = var.s3_secret
    S3_SECRET_KEY_USERNAME = var.s3_secret_key_username
    S3_SECRET_KEY_PASSWORD = var.s3_secret_key_password
    CLUSTER_DOMAIN         = var.cluster_domain
  }
  chart_release = "cosmotech-modeling-api"
}

resource "helm_release" "modeling_api" {
  namespace  = var.tenant
  name       = local.chart_release
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_tag

  values = [local.chart_values]

  force_update  = true
  recreate_pods = true

  lifecycle {
    replace_triggered_by = [
      terraform_data.helm_release_trigger,
    ]
  }
}

data "kubernetes_resources" "helm_release_secret" {
  api_version    = "v1"
  kind           = "Secret"
  label_selector = "owner=helm,name=${local.chart_release}"
}

resource "terraform_data" "helm_release_trigger" {
  input = {
    version      = var.chart_tag
    values       = local.chart_values
    values_sha1  = sha1(local.chart_values)
    helm_release = data.kubernetes_resources.helm_release_secret
  }
}
