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

  # Gateway path under which the Cosmo Tech Run API is exposed (https://<cluster_domain>/<namespace>/run-api)
  cosmotech_run_api_route = "run-api"

  # Service address format: "<host>:<port>/<path>"
  cosmotech_run_api_service_host = try(split("/", var.cosmotech_run_api_service_address)[0], "")
  cosmotech_run_api_service_path = try(trimprefix(var.cosmotech_run_api_service_address, local.cosmotech_run_api_service_host), "")

  # Services exposed through the gateway, each one only enabled when its module is part of the tenant recipe.
  # "openapi" is optional: omit it (or set it to null) for services without OpenAPI contract.
  gateway_services = [
    {
      enabled = contains(var.tenant_recipe_modules, "chart_cosmotech_run_api")
      routes = [
        {
          id         = "cosmotech-run-api"
          uri        = "http://${local.cosmotech_run_api_service_host}"
          predicates = ["Path=/${local.cosmotech_run_api_route}/**"]
          filters    = ["RewritePath=^/${var.namespace}/${local.cosmotech_run_api_route}/(?<segment>.*), ${local.cosmotech_run_api_service_path}/$\\{segment}"]
        },
      ]
      openapi = {
        name          = "cosmotech-run-api"
        uri           = "http://${local.cosmotech_run_api_service_host}"
        document_path = "${local.cosmotech_run_api_service_path}/openapi.yaml"
        server_url    = "/${var.namespace}/${local.cosmotech_run_api_route}"
      }
    },
  ]

  gateway_enabled_services = [for service in local.gateway_services : service if service.enabled]
  gateway_openapi_services = [for service in local.gateway_enabled_services : service.openapi if try(service.openapi, null) != null]

  # Public route serving each OpenAPI contract under /openapi/<name>
  gateway_openapi_routes = [
    for openapi in local.gateway_openapi_services : {
      id         = "${openapi.name}-openapi"
      uri        = openapi.uri
      predicates = ["Path=/openapi/${openapi.name}"]
      filters    = ["RewritePath=^/${var.namespace}/openapi/${openapi.name}$, ${openapi.document_path}"]
    }
  ]

  gateway_routes              = concat(flatten([for service in local.gateway_enabled_services : service.routes]), local.gateway_openapi_routes)
  gateway_openapi_server_urls = { for openapi in local.gateway_openapi_services : "[/openapi/${openapi.name}]" => openapi.server_url }
  gateway_swagger_urls = concat(
    [{ name = "cosmotech-gateway", url = "/v3/api-docs" }],
    [for openapi in local.gateway_openapi_services : { name = openapi.name, url = "/openapi/${openapi.name}" }],
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
