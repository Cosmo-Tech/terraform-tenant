locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    PERSISTENCE_MASTER_SIZE           = var.size_master
    PERSISTENCE_MASTER_PVC            = var.pvc_master
    PERSISTENCE_MASTER_STORAGE_CLASS  = var.pvc_master_storage_class
    PERSISTENCE_REPLICA_SIZE          = var.size_replica
    PERSISTENCE_REPLICA_PVC           = var.pvc_replica
    PERSISTENCE_REPLICA_STORAGE_CLASS = var.pvc_replica_storage_class
    REDIS_SECRET                      = kubernetes_secret.redis.metadata[0].name
    REDIS_PASSWORD                    = kubernetes_secret.redis.data.password
    REDIS_IMAGE_REPOSITORY            = var.redis_image_repository
    REDIS_IMAGE_TAG                   = var.redis_image_tag
    GENERIC_SHELL_IMAGE_REPOSITORY    = var.generic_shell_image_repository
    GENERIC_SHELL_IMAGE_TAG           = var.generic_shell_image_tag
    IMAGE_REGISTRY                    = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET        = var.image_registry_auth_secret
  }
}


resource "random_password" "password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


resource "kubernetes_secret" "redis" {
  metadata {
    namespace = var.tenant
    name      = "${var.chart_release}-config"
  }

  data = {
    "password" = random_password.password.result
  }

  type = "Opaque"
}


resource "helm_release" "redis" {
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
    var.pvc_replica,
    kubernetes_secret.redis,
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
