terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1.3"
    }
  }
}

locals {
  cosmotech_superset_client_secret = data.kubernetes_secret.superset_keycloak_client_secret.data["superset-client-secret"]
  oauth_provider_metadata_url = "https://${var.cluster_domain}/keycloak/realms/${var.tenant}/.well-known/openid-configuration"
  new_oauth_providers = concat(
    jsondecode(
        data.kubernetes_config_map.superset_oauth_providers.data != null ? data.kubernetes_config_map.superset_oauth_providers.data["oauth-providers"] : "[]"
    ),
    jsondecode(templatefile("${path.module}/templates/oauth_providers.json",
      {
        TENANT_NAME = var.tenant,
        SUPERSET_CLIENT_SECRET = local.cosmotech_superset_client_secret,
        OAUTH_PROVIDER_METADATA_URL = local.oauth_provider_metadata_url,
        COSMOTECH_SUPERSET_CLIENT_ID = var.superset_keycloak_client_name
      }))
  )
  superset_oauth_providers_configmap_descriptor = templatefile("${path.module}/templates/configmap_oauth_poviders.yaml",
    {
      SUPERSET_OAUTH_PROVIDERS_CONFIG = jsonencode(local.new_oauth_providers),
      SUPERSET_OAUTH_PROVIDERS_CONFIGMAP_NAME = var.superset_oauth_providers_configmap_name,
      SUPERSET_NAMESPACE = var.superset_namespace,
    })
}

data "kubernetes_config_map" "superset_oauth_providers" {
  metadata {
    name      = var.superset_oauth_providers_configmap_name
    namespace = var.superset_namespace
  }
}

data "kubernetes_secret" "superset_keycloak_client_secret" {
  metadata {
    name      = var.superset_keycloak_client_secret_name
    namespace = var.tenant
  }
}

resource "kubectl_manifest" "superset_oauth_providers" {
  yaml_body = local.superset_oauth_providers_configmap_descriptor
}


