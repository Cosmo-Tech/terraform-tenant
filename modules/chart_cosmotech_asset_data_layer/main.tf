locals {
  chart_values_file = templatefile("${path.module}/values.yaml", local.chart_values)
  chart_values = {
    CLUSTER_DOMAIN              = var.cluster_domain
    NAMESPACE                   = var.tenant
    PERSISTENCE_PVC             = var.persistence_pvc
    PERSISTENCE_SIZE            = var.persistence_size
    PERSISTENCE_STORAGE_CLASS   = var.persistence_pvc_storage_class
    POSTGRESQL_DATABASE         = var.postgresql_database
    POSTGRESQL_PASSWORD         = var.postgresql_password
    POSTGRESQL_USERNAME         = var.postgresql_username
    COSMOTECH_API_CLIENT_ID     = var.cosmotech_api_client_id
    COSMOTECH_API_CLIENT_SECRET = var.cosmotech_api_client_secret
    S3_HOST                     = var.s3_host
    S3_PORT                     = var.s3_port
    S3_BUCKET                   = var.s3_bucket
    S3_ACCESS_KEY               = var.s3_secret_key_username
    S3_SECRET_KEY               = var.s3_secret_key_password
    KEYCLOAK_CLIENT_ID          = var.keycloak_client_id
    # HARBOR_PASSWORD             = var.harbor_password
    WEBHOOK_AUTH_TOKEN          = random_password.webhook_token.result
    IMAGE_REGISTRY              = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET  = var.image_registry_auth_secret
    IMAGE_TAG                   = var.image_tag
  }
}

resource "random_password" "webhook_token" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


data "kubernetes_secret" "my_secret" {
  metadata {
    name      = "seaweedfs-s3"
    namespace = var.tenant
  }
}

# 2. Décodage du JSON et extraction de la secretKey de cosmotech_api
locals {
  # Décodage de la chaîne JSON stockée dans la clé config.json
  config_data = jsondecode(data.kubernetes_secret.my_secret.data["config.json"])

  # Filtrage pour trouver l'identité "cosmotech_api" et extraire sa secretKey
  cosmotech_secret_key = [
    for identity in local.config_data.identities :
    identity.credentials[0].secretKey
    if identity.name == "cosmotech_api"
  ][0]
}

resource "helm_release" "cosmotech_asset_data_layer" {
  namespace  = var.tenant
  name       = "${var.chart_release}-${var.tenant}"
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

