locals {
  public_url         = "/${var.namespace}/${var.webapp_name}"
  webapp_base_url    = "https://${var.cluster_domain}${local.public_url}"
  keycloak_client_id = var.keycloak_client_id # created in config_keycloak_realm (client_webapp.tf)
  keycloak_realm_url = "https://${var.cluster_domain}/keycloak/realms/${var.namespace}"
  run_api_url        = "https://${var.cluster_domain}/${var.namespace}/api"

  global_configuration_common = {
    APP_REGISTRATION_CLIENT_ID    = ""
    AUTH_KEYCLOAK_CLIENT_ID       = local.keycloak_client_id
    AUTH_KEYCLOAK_REALM           = local.keycloak_realm_url
    AUTH_KEYCLOAK_ROLES_JWT_CLAIM = "userRoles"
    AZURE_TENANT_ID               = ""
    COSMOTECH_API_SCOPE           = "https://${var.cluster_domain}/platform"
    ORGANIZATION_ID               = var.organization_id
    PUBLIC_URL                    = local.public_url
    WORKSPACES_IDS_FILTER         = null
  }

  global_configuration_api = var.asset_data_layer_enabled ? {
    RUN_API_URL = local.run_api_url
    ADL_API_URL = "https://${var.cluster_domain}/${var.namespace}/asset"
    } : {
    DEFAULT_BASE_PATH = local.run_api_url
  }

  global_configuration = merge(
    local.global_configuration_common,
    local.global_configuration_api,
    var.extra_global_configuration,
  )

  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    WEBAPP_NAME          = var.webapp_name
    CLUSTER_DOMAIN       = var.cluster_domain
    PUBLIC_URL           = local.public_url
    KEYCLOAK_REALM_URL   = local.keycloak_realm_url
    COSMOTECH_API_URL    = local.run_api_url
    POWERBI_TENANT_ID    = var.powerbi_tenant_id
    GLOBAL_CONFIGURATION = jsonencode(local.global_configuration) # JSON is valid YAML
    REGISTRY             = var.registry
    REGISTRY_AUTH_SECRET = var.registry_auth_secret
    IMAGE_NAME_SERVER    = var.image_name_server
    IMAGE_TAG_SERVER     = var.image_tag_server
    IMAGE_NAME_FUNCTIONS = var.image_name_functions
    IMAGE_TAG_FUNCTIONS  = var.image_tag_functions
  }
}


data "kubernetes_secret" "superset" {
  metadata {
    namespace = "superset"
    name      = "superset"
  }
}

# Optional: created by the "config_powerbi_app" module (Azure only)
data "kubernetes_secret" "powerbi" {
  metadata {
    namespace = var.namespace
    name      = "${var.webapp_name}-powerbi-client"
  }
}


resource "helm_release" "cosmotech_business_webapp" {
  namespace  = var.namespace
  name       = var.webapp_name
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_tag

  values = [
    local.chart_values_file
  ]

  # Secrets are kept out of the rendered values (and of the replace trigger)
  set_sensitive = [
    {
      name  = "superset.superuser.password"
      value = try(data.kubernetes_secret.superset.data["superset-password"], "")
    },
    {
      name  = "powerbi.clientId"
      value = try(data.kubernetes_secret.powerbi.data["client_id"], "")
    },
    {
      name  = "powerbi.clientSecret"
      value = try(data.kubernetes_secret.powerbi.data["client_secret"], "")
    },
  ]

  force_update  = true
  recreate_pods = true

  lifecycle {
    replace_triggered_by = [
      terraform_data.helm_release_trigger,
    ]
  }
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
  namespace      = var.namespace
  label_selector = "owner=helm,name=${var.webapp_name}"
}
