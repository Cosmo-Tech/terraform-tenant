locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    PERSISTENCE_MASTER_SIZE          = var.size_master
    PERSISTENCE_MASTER_PVC           = var.pvc_master
    PERSISTENCE_MASTER_STORAGE_CLASS = var.pvc_master_storage_class
    PERSISTENCE_MASTER_ACCESS_MODES  = var.pvc_master_access_modes
    PERSISTENCE_VOLUME_SIZE          = var.size_volume
    PERSISTENCE_VOLUME_PVC           = var.pvc_volume
    PERSISTENCE_VOLUME_STORAGE_CLASS = var.pvc_volume_storage_class
    PERSISTENCE_VOLUME_ACCESS_MODES  = var.pvc_volume_access_modes
    DATABASE_HOST                    = var.database_host
    DATABASE_PORT                    = var.database_port
    DATABASE_NAME                    = var.database_seaweedfs_name
    DATABASE_USER                    = var.database_seaweedfs_user
    DATABASE_SECRET                  = var.database_seaweedfs_secret
    S3_INIT_BUCKETS                  = ["${local.s3_argo_workflows_bucket}", "${local.s3_cosmotech_api_bucket}"]
    S3_SECRET                        = kubernetes_secret.s3_secret.metadata[0].name
    S3_PORT                          = local.s3_port
    FILER_ENDPOINT                   = "http://${var.chart_release}-filer.${var.tenant}.svc.cluster.local:8888"
    IMAGE_REGISTRY                   = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET       = var.image_registry_auth_secret
    POSTGRESQL_IMAGE_REPOSITORY      = var.postgresql_image_repository
    POSTGRESQL_IMAGE_TAG             = var.postgresql_image_tag
  }

  s3_host = "${helm_release.seaweedfs.name}-s3.${helm_release.seaweedfs.namespace}.svc.cluster.local"
  s3_port = "8333"

  s3_argo_workflows_bucket              = "argo-workflows"
  s3_argo_workflows_username            = "argo_workflows"
  s3_argo_workflows_password            = random_password.s3_argo_workflows_password.result
  s3_secret_key_argo_workflows_username = "argo-workflows-username"
  s3_secret_key_argo_workflows_password = "argo-workflows-password"

  s3_cosmotech_api_bucket              = "cosmotech-api"
  s3_cosmotech_api_username            = "cosmotech_api"
  s3_cosmotech_api_password            = random_password.s3_cosmotech_api_password.result
  s3_secret_key_cosmotech_api_username = "cosmotech-api-username"
  s3_secret_key_cosmotech_api_password = "cosmotech-api-password"
}


resource "random_password" "s3_argo_workflows_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


resource "random_password" "s3_cosmotech_api_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


resource "kubernetes_secret" "s3_secret" {
  metadata {
    namespace = var.tenant
    name      = "${var.chart_release}-s3"
  }

  data = {
    "${local.s3_secret_key_argo_workflows_username}" = local.s3_argo_workflows_username
    "${local.s3_secret_key_argo_workflows_password}" = local.s3_argo_workflows_password
    "${local.s3_secret_key_cosmotech_api_username}"  = local.s3_cosmotech_api_username
    "${local.s3_secret_key_cosmotech_api_password}"  = local.s3_cosmotech_api_password
    "config.json" = templatefile("${path.module}/templates/s3_config.json", {
      "ARGO_WORKFLOWS_USERNAME" = local.s3_argo_workflows_username
      "ARGO_WORKFLOWS_PASSWORD" = local.s3_argo_workflows_password
      "COSMOTECH_API_USERNAME"  = local.s3_cosmotech_api_username
      "COSMOTECH_API_PASSWORD"  = local.s3_cosmotech_api_password
    })
  }

  type = "Opaque"
}


resource "helm_release" "seaweedfs" {
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
    var.pvc_master,
    var.pvc_volume,
    var.database_seaweedfs_name,
    var.database_seaweedfs_secret,
    kubernetes_secret.s3_secret,
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
