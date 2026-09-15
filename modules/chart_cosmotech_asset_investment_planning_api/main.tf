terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

locals {
  chart_values_file = templatefile("${path.module}/templates/values.yaml", local.chart_values)
  chart_values = {
    NAMESPACE                                          = var.namespace
    REGISTRY                                           = var.registry
    REGISTRY_AUTH_SECRET                               = var.registry_auth_secret
    COSMOTECH_ASSET_INVESTMENT_PLANNING_API_IMAGE_NAME = var.cosmotech_asset_investment_planning_api_image_name
    COSMOTECH_ASSET_INVESTMENT_PLANNING_API_IMAGE_TAG  = var.cosmotech_asset_investment_planning_api_image_tag
    DB_HOST                                            = var.database_host
    DB_PORT                                            = var.database_port
    DB_NAME                                            = var.database_name
    DB_ADMIN_USERNAME                                  = local.database_admin_username
    DB_ADMIN_PASSWORD                                  = local.database_admin_password
    DB_SCHEMA_NAME                                     = local.database_schema_name
    CLUSTER_DOMAIN                                     = var.cluster_domain
  }

  database_admin_username = "cosmotech_api_admin"
  database_admin_password = random_password.api_admin_password.result
  database_schema_name    = "cosmotech_asset_investment_planning"
}


resource "helm_release" "cosmotech_asset_investment_planning_api" {
  namespace  = var.namespace
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
    var.namespace,
    kubectl_manifest.initdb,       # internal
    postgresql_database.cosmotech, # external
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


resource "random_password" "api_admin_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}
