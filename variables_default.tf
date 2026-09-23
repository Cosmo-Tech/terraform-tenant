## This file allows to fix defaults values, and also allow to override them from terraform.tfvars, CLI arguments or TF_VAR env variables.


# PostgreSQL (internal = CloudNative-PG, "cnpg")
variable "postgresql_image_name" { default = "postgres-cloudnative-pg-fips" } ## Note: not only used in postgresql module, but also in others modules to ensure psql is the same everywhere
variable "postgresql_image_tag" { default = "18" }                            ## Note: not only used in postgresql module, but also in others modules to ensure psql is the same everywhere
variable "postgresql_storage_size" { default = 8 }


## PostgreSQL (external)
variable "use_external_postgresql" { default = false }
variable "external_postgresql_host" { default = "changeme" }
variable "external_postgresql_port" { default = "5432" }
variable "external_postgresql_username" { default = "changeme" }
variable "external_postgresql_password" { default = "changeme" }


## SeaweedFS
variable "seaweedfs_chart_name" { default = "seaweedfs" }
variable "seaweedfs_chart_tag" { default = "6.0.4" }
variable "seaweedfs_image_name" { default = "seaweedfs-iamguarded" }
variable "seaweedfs_image_tag" { default = "4.43" }
variable "seaweedfs_storage_size" { default = 32 }


## Argo Workflows
variable "argo_workflows_chart_name" { default = "argo-workflows" }
variable "argo_workflows_chart_tag" { default = "13.0.6" }
variable "argo_workflows_image_prefix" { default = "argo-workflow" } ## Prefix, because Argo Workflows is composed of multiple images
variable "argo_workflows_image_tag" { default = "4.0.10" }           ## All Argo Workflows images have the same tag


## Redis
variable "redis_chart_name" { default = "redis" }
variable "redis_chart_tag" { default = "25.3.8" }
variable "redis_image_name" { default = "redis-server-iamguarded" }
variable "redis_image_tag" { default = "8.6.3" }
variable "redis_storage_size" { default = 16 }


## Cosmo Tech Running API (Formerly "Cosmo Tech API")
variable "cosmotech_run_api_chart_name" { default = "cosmotech-api" }
variable "cosmotech_run_api_chart_tag" { default = "5.2.1" }
variable "cosmotech_run_api_image_name" { default = "cosmotech-api" }
variable "cosmotech_run_api_image_tag" { default = "5.2.0" }
variable "mcp_enabled" { default = false }
variable "mcp_dashboard_enabled" { default = false }
variable "mcp_paths_to_exclude" { default = "" }


## Cosmo Tech Modeling API
variable "cosmotech_modeling_api_chart_name" { default = "cosmotech-modeling-api" }
variable "cosmotech_modeling_api_chart_tag" { default = "0.7.0" }
variable "cosmotech_modeling_api_image_name" { default = "cosmotech-modeling-api" }
variable "cosmotech_modeling_api_image_tag" { default = "12.3.0" }
variable "cosmotech_modeling_api_storage_size" { default = 8 }


## Cosmo Tech Asset Data Layer
variable "cosmotech_asset_data_layer_chart_name" { default = "cosmotech-asset-data-layer-api" }
variable "cosmotech_asset_data_layer_chart_tag" { default = "0.2.0" }
variable "cosmotech_asset_data_layer_image_name" { default = "cosmotech-asset-data-layer" }
variable "cosmotech_asset_data_layer_image_tag" { default = "main" }
variable "cosmotech_asset_data_layer_storage_size" { default = 8 }


## Cosmo Tech Asset Investment Planning API
variable "cosmotech_asset_investment_planning_api_chart_name" { default = "cosmotech-asset-investment-planning-api" }
variable "cosmotech_asset_investment_planning_api_chart_tag" { default = "0.2.0" }
variable "cosmotech_asset_investment_planning_api_image_name" { default = "cosmotech-asset-investment-planning-api" }
variable "cosmotech_asset_investment_planning_api_image_tag" { default = "main" }
variable "cosmotech_asset_investment_planning_api_storage_size" { default = 8 }


## Cosmo Tech Asset Investment Planning Webapp
variable "cosmotech_asset_investment_planning_webapp_chart_name" { default = "cosmotech-asset-investment-planning-webapp" }
variable "cosmotech_asset_investment_planning_webapp_chart_tag" { default = "0.2.0" }
variable "cosmotech_asset_investment_planning_webapp_image_name" { default = "cosmotech-asset-investment-planning-webapp" }
variable "cosmotech_asset_investment_planning_webapp_image_tag" { default = "main" }


## Global
variable "registry" { default = "registry.cosmotech.com" }
variable "registry_auth_secret" { default = "registry-auth-cosmotech" }

variable "chart_prefix_product" { default = "product-charts/" }
variable "image_prefix_product" { default = "product/" }

variable "chart_prefix_thirdparty" { default = "proxy-chainguard-charts/" }
variable "image_prefix_thirdparty" { default = "proxy-chainguard/cosmotech/" }

variable "generic_shell_image_name" { default = "os-shell-iamguarded" }
variable "generic_shell_image_tag" { default = "latest" }

locals {
  module_storage_kob_tag   = "main"
  module_storage_azure_tag = "main"
  module_storage_aws_tag   = "main"
  module_storage_gcp_tag   = "main"
}
