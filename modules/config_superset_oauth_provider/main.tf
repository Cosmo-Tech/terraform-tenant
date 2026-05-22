terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1.3"
    }
  }
}

locals {
  keycloak_client        = "cosmotech-client-superset"
  keycloak_client_secret = data.kubernetes_secret.keycloak_client_secret.data["client-secret"]
  keycloak_metadata_url  = "https://${var.cluster_domain}/keycloak/realms/${var.tenant}/.well-known/openid-configuration"

  superset_namespace             = "superset"
  oauth_providers_configmap_name = "superset-oauth-providers"
  # new_oauth_providers = concat(
  #   jsondecode(data.kubernetes_config_map.oauth_providers.data == null ? "[]" : data.kubernetes_config_map.oauth_providers.data["oauth-providers"]),
  #   jsondecode(templatefile("${path.module}/templates/oauth_providers.json", {
  #     TENANT_NAME            = var.tenant,
  #     KEYCLOAK_METADATA_URL  = local.keycloak_metadata_url,
  #     KEYCLOAK_CLIENT_NAME   = local.keycloak_client
  #     KEYCLOAK_CLIENT_SECRET = local.keycloak_client_secret,
  #   }))
  # )

  # Create new oauth provider for the tenant
  tenant_oauth_provider = jsondecode(templatefile("${path.module}/templates/oauth_providers.json", {
    TENANT_NAME            = var.tenant,
    KEYCLOAK_METADATA_URL  = local.keycloak_metadata_url,
    KEYCLOAK_CLIENT_NAME   = local.keycloak_client,
    KEYCLOAK_CLIENT_SECRET = local.keycloak_client_secret,
  }))

  # # Get current oauth providers list (empty list if the configmap doesn't exist)
  current_oauth_providers_list = jsondecode(
    data.kubernetes_config_map.oauth_providers.data == null ? "[]" :
    lookup(data.kubernetes_config_map.oauth_providers.data, "oauth-providers", "[]")
  )

  # Replace the existing tenant oauth provider in the list
  new_oauth_providers_list = concat(
    [for provider in local.current_oauth_providers_list : provider if provider.name != var.tenant],
    local.tenant_oauth_provider
  )

  # Fill the configmap template
  oauth_providers_configmap_descriptor = templatefile("${path.module}/templates/configmap_oauth_poviders.yaml", {
    CONFIGMAP_NAME       = local.oauth_providers_configmap_name,
    CONFIGMAP_NAMESPACE  = local.superset_namespace,
    OAUTH_PROVIDERS_LIST = jsonencode(local.new_oauth_providers_list),
  })
}


data "kubernetes_config_map" "oauth_providers" {
  metadata {
    name      = local.oauth_providers_configmap_name
    namespace = local.superset_namespace
  }
}

data "kubernetes_secret" "keycloak_client_secret" {
  metadata {
    name      = "keycloak-superset"
    namespace = var.tenant
  }
}


resource "kubectl_manifest" "oauth_providers" {
  yaml_body = local.oauth_providers_configmap_descriptor
}



# Restart Superset to use the new configmap (only if the new configmap is different from the previous one)
resource "null_resource" "restart_superset" {
  triggers = {
    sha1-configmap-data = sha1(kubectl_manifest.oauth_providers.yaml_body)
  }

  provisioner "local-exec" {
    command = "kubectl -n ${local.superset_namespace} rollout restart deployment superset-web"
  }

  depends_on = [
    data.kubernetes_config_map.oauth_providers,
  ]
}



# # Restart Superset to use the new configmap (only if the new configmap is different from the previous one)
# resource "terraform_data" "restart_superset" {

#   triggers_replace = {
#     configmap_changed = local.oauth_providers_configmap_descriptor != (
#       data.kubernetes_config_map.oauth_providers.data == null ? "" : jsonencode(data.kubernetes_config_map.oauth_providers.data)
#     )
#   }

#   provisioner "local-exec" {
#     command = self.output.configmap_changed ? "kubectl -n ${local.superset_namespace} rollout restart deployment superset-web" : "echo 'No config change, skipping restart'"
#   }

#   depends_on = [
#     kubectl_manifest.oauth_providers
#   ]
# }
