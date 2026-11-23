locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    NAMESPACE                    = var.namespace
    REGISTRY                     = var.registry
    REGISTRY_AUTH_SECRET         = var.registry_auth_secret
    COSMOTECH_GATEWAY_IMAGE_NAME = var.cosmotech_gateway_image_name
    COSMOTECH_GATEWAY_IMAGE_TAG  = var.cosmotech_gateway_image_tag
    CLUSTER_DOMAIN               = var.cluster_domain
    KEYCLOAK_GATEWAY_CLIENT_ID   = var.keycloak_gateway_client_id
    GATEWAY_ROUTES               = local.gateway_routes
    GATEWAY_OPENAPI_SERVER_URLS  = local.gateway_openapi_server_urls
    GATEWAY_SWAGGER_URLS         = local.gateway_swagger_urls
  }
  chart_release_name = "${var.chart_release}-${var.namespace}"

  # Service address format: "<host>:<port>/<path>"
  cosmotech_run_api_service_host = try(split("/", var.cosmotech_run_api_service_address)[0], "")
  cosmotech_run_api_service_path = try(trimprefix(var.cosmotech_run_api_service_address, local.cosmotech_run_api_service_host), "")

  run_api_enabled      = contains(var.tenant_recipe_modules, "chart_cosmotech_run_api")
  modeling_api_enabled = contains(var.tenant_recipe_modules, "chart_cosmotech_modeling_api")

  # Each service declares its own routes, OpenAPI route and Swagger entry, only when its module is part of the tenant recipe.

  # Cosmo Tech Run API: API served under /<suffix>/**, OpenAPI contract read from the service path
  run_api_routes = local.run_api_enabled ? [
    {
      id         = "cosmotech-run-api"
      uri        = "http://${local.cosmotech_run_api_service_host}"
      predicates = ["Path=/${var.cosmotech_run_api_route_suffix}/**"]
      filters    = ["RewritePath=^/${var.namespace}/${var.cosmotech_run_api_route_suffix}/(?<segment>.*), ${local.cosmotech_run_api_service_path}/$\\{segment}"]
    },
    {
      id         = "cosmotech-run-api-openapi"
      uri        = "http://${local.cosmotech_run_api_service_host}"
      predicates = ["Path=/openapi/cosmotech-run-api"]
      filters    = ["RewritePath=^/${var.namespace}/openapi/cosmotech-run-api$, ${local.cosmotech_run_api_service_path}/openapi.yaml"]
    },
  ] : []

  # Cosmo Tech Modeling API: API served under /<suffix>/**, prefix stripped before forwarding
  modeling_api_routes = local.modeling_api_enabled ? [
    {
      id         = "cosmotech-modeling-api"
      uri        = "http://${var.cosmotech_modeling_api_service_address}"
      predicates = ["Path=/${var.cosmotech_modeling_api_route_suffix}/**"]
      filters    = ["StripPrefix=2"]
    },
    {
      id         = "cosmotech-modeling-api-openapi"
      uri        = "http://${var.cosmotech_modeling_api_service_address}"
      predicates = ["Path=/openapi/cosmotech-modeling-api"]
      filters    = ["RewritePath=^/${var.namespace}/openapi/cosmotech-modeling-api$, /openapi.yaml"]
    },
  ] : []

  gateway_routes = concat(local.run_api_routes, local.modeling_api_routes)

  gateway_openapi_server_urls = merge(
    local.run_api_enabled ? { "[/openapi/cosmotech-run-api]" = "/${var.namespace}/${var.cosmotech_run_api_route_suffix}" } : {},
    local.modeling_api_enabled ? { "[/openapi/cosmotech-modeling-api]" = "/${var.namespace}/${var.cosmotech_modeling_api_route_suffix}" } : {},
  )

  gateway_swagger_urls = concat(
    [{ name = "cosmotech-gateway", url = "/v3/api-docs" }],
    local.run_api_enabled ? [{ name = "cosmotech-run-api", url = "/openapi/cosmotech-run-api" }] : [],
    local.modeling_api_enabled ? [{ name = "cosmotech-modeling-api", url = "/openapi/cosmotech-modeling-api" }] : [],
  )
}


resource "helm_release" "cosmotech_gateway" {
  namespace  = var.namespace
  name       = local.chart_release_name
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
  namespace      = var.namespace
  label_selector = "owner=helm,name=${local.chart_release_name}"
}
