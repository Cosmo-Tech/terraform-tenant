locals {
  cosmotech_superset_client_secret = var.cosmotech_superset_client_secret
  oauth_provider_metadata_url = "https://${var.cluster_domain}/keycloak/realms/${var.tenant}/.well-known/openid-configuration"
  new_oauth_providers = concat(
    jsondecode(
        data.kubernetes_config_map.superset_oauth_providers.data != null ? data.kubernetes_config_map.superset_oauth_providers.data["oauth-providers"] : "[]"
    ),
    jsondecode(templatefile("${path.module}/templates/oauth_providers.json",
      {
        TENANT_NAME = var.tenant,
        SUPERSET_CLIENT_SECRET = var.cosmotech_superset_client_secret,
        OAUTH_PROVIDER_METADATA_URL = local.oauth_provider_metadata_url,
        COSMOTECH_SUPERSET_CLIENT_ID = var.superset_keycloak_client_name
      }))
  )
}

data "kubernetes_config_map" "superset_oauth_providers" {
  metadata {
    name      = var.superset_oauth_providers_configmap_name
    namespace = var.superset_namespace
  }
}

resource "kubernetes_config_map" "superset_oauth_providers" {

  metadata {
    name      = var.superset_oauth_providers_configmap_name
    namespace = var.superset_namespace
  }

  data = {
    "oauth-providers" = jsonencode(local.new_oauth_providers)
  }

}


