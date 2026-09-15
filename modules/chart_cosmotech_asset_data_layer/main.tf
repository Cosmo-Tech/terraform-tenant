locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    NAMESPACE                             = var.namespace
    REGISTRY                              = var.registry
    REGISTRY_AUTH_SECRET                  = var.registry_auth_secret
    COSMOTECH_ASSET_DATA_LAYER_IMAGE_NAME = var.cosmotech_asset_data_layer_image_name
    COSMOTECH_ASSET_DATA_LAYER_IMAGE_TAG  = var.cosmotech_asset_data_layer_image_tag
    PERSISTENCE_PVC                       = var.persistence_pvc
    PERSISTENCE_SIZE                      = var.persistence_size
    PERSISTENCE_STORAGE_CLASS             = var.pvc_storage_class
    POSTGRESQL_HOST                       = var.postgresql_host
    POSTGRESQL_PORT                       = var.postgresql_port
    POSTGRESQL_DATABASE                   = var.postgresql_database
    POSTGRESQL_USERNAME                   = data.kubernetes_secret.postgresql-config.data["username"]
    POSTGRESQL_PASSWORD                   = data.kubernetes_secret.postgresql-config.data["password"]
    COSMOTECH_API_CLIENT_ID               = var.cosmotech_api_client_id
    COSMOTECH_API_CLIENT_SECRET           = var.cosmotech_api_client_secret
    # S3_HOST                     = var.s3_host
    # S3_PORT                     = var.s3_port
    # S3_BUCKET                   = var.s3_bucket
    # S3_ACCESS_KEY               = var.s3_secret_key_username
    # S3_SECRET_KEY               = var.s3_secret_key_password
    KEYCLOAK_CLIENT_ID = var.keycloak_client_id
    CLUSTER_DOMAIN     = var.cluster_domain
  }
}


resource "helm_release" "cosmotech_asset_data_layer" {
  namespace  = var.namespace
  name       = "${var.chart_release}-${var.namespace}"
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_tag

  values = [
    local.chart_values_file
  ]

  force_update  = true
  recreate_pods = true

  lifecycle {
    replace_triggered_by = [
      terraform_data.helm_release_trigger,
    ]
  }

  depends_on = [
    var.namespace,
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


data "kubernetes_secret" "postgresql-config" {
  metadata {
    namespace = var.namespace
    name      = "postgresql-config"
  }
}
