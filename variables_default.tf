## This file allows to fix defaults values, and also allow to override them from terraform.tfvars, CLI arguments or TF_VAR env variables.


## Generic shell (used to run init containers, scripts etc...)
variable "generic_shell_image_registry" { default = "cgr.dev" }
variable "generic_shell_image_registry_auth_secret" { default = "registry-auth-cgrdev" }
variable "generic_shell_image_repository" { default = "cosmotech/os-shell-iamguarded" }
variable "generic_shell_image_tag" { default = "latest" }


# PostgreSQL (internal = CloudNative-PG, "cnpg")
variable "postgresql_chart_repository" { default = "oci://cgr.dev/cosmotech/postgres-cloudnative-pg-fips" }
variable "postgresql_chart_name" { default = "postgresql" }
variable "postgresql_chart_tag" { default = "18" }
variable "postgresql_image_registry" { default = "cgr.dev" } ## Note: not only used in postgresql module, but also in others modules to ensure psql is the same everywhere
variable "postgresql_image_registry_auth_secret" { default = "registry-auth-cgrdev" }
variable "postgresql_image_repository" { default = "cosmotech/postgres-cloudnative-pg-fips" } ## Note: not only used in postgresql module, but also in others modules to ensure psql is the same everywhere
variable "postgresql_image_tag" { default = "18" }                                            ## Note: not only used in postgresql module, but also in others modules to ensure psql is the same everywhere
variable "postgresql_storage_size" { default = 8 }


## PostgreSQL (external)
variable "use_external_postgresql" { default = false }
variable "external_postgresql_host" { default = "changeme" }
variable "external_postgresql_port" { default = "5432" }
variable "external_postgresql_username" { default = "changeme" }
variable "external_postgresql_password" { default = "changeme" }


## SeaweedFS
variable "seaweedfs_chart_repository" { default = "oci://cgr.dev/cosmotech/iamguarded-charts" }
variable "seaweedfs_chart_name" { default = "seaweedfs" }
variable "seaweedfs_chart_tag" { default = "6.0.4" }
variable "seaweedfs_image_registry" { default = "cgr.dev" }
variable "seaweedfs_image_registry_auth_secret" { default = "registry-auth-cgrdev" }
variable "seaweedfs_image_repository" { default = "cosmotech/seaweedfs-iamguarded" }
variable "seaweedfs_image_tag" { default = "4.43" }
variable "seaweedfs_storage_size" { default = 32 }


## Argo Workflows
variable "argo_chart_repository" { default = "oci://cgr.dev/cosmotech/iamguarded-charts" }
variable "argo_chart_name" { default = "argo-workflows" }
variable "argo_chart_tag" { default = "13.0.6" }
variable "argo_image_registry" { default = "cgr.dev" }
variable "argo_image_registry_auth_secret" { default = "registry-auth-cgrdev" }
# variable "argo_image_repository" { default = "" } ## Not defined because Argo Workflows is composed of multiple images
variable "argo_image_tag" { default = "4.0.10" } ## All Argo Workflows images have the same tag


## Redis
variable "redis_chart_repository" { default = "oci://cgr.dev/cosmotech/iamguarded-charts" }
variable "redis_chart_name" { default = "redis" }
variable "redis_chart_tag" { default = "25.3.8" }
variable "redis_image_registry" { default = "cgr.dev" }
variable "redis_image_registry_auth_secret" { default = "registry-auth-cgrdev" }
variable "redis_image_repository" { default = "cosmotech/redis-server-iamguarded" }
variable "redis_image_tag" { default = "8.6.3" }
variable "redis_storage_size" { default = 16 }


## Cosmo Tech Running API (Formerly "Cosmo Tech API")
variable "cosmotech_running_api_chart_repository" { default = "https://cosmo-tech.github.io/helm-charts" }
variable "cosmotech_running_api_chart_name" { default = "cosmotech-api" }
variable "cosmotech_running_api_chart_tag" { default = "5.1.0" }
variable "cosmotech_running_api_image_registry" { default = "ghcr.io" }
variable "cosmotech_running_api_image_registry_auth_secret" { default = "registry-auth-ghcrio" }
variable "cosmotech_running_api_image_repository" { default = "cosmo-tech/cosmotech-api" }
variable "cosmotech_running_api_image_tag" { default = "12.3.0" }


## Cosmo Tech Modeling API
variable "cosmotech_modeling_api_chart_repository" { default = "https://cosmo-tech.github.io/helm-charts" }
variable "cosmotech_modeling_api_chart_name" { default = "cosmotech-modeling-api" }
variable "cosmotech_modeling_api_chart_tag" { default = "0.7.0" }
variable "cosmotech_modeling_api_image_registry" { default = "ghcr.io" }
variable "cosmotech_modeling_api_image_registry_auth_secret" { default = "registry-auth-ghcrio" }
variable "cosmotech_modeling_api_image_repository" { default = "cosmo-tech/cosmotech-modeling-api" }
variable "cosmotech_modeling_api_image_tag" { default = "12.3.0" }
variable "cosmotech_modeling_api_storage_size" { default = 8 }


## Cosmo Tech Asset Data Layer
variable "cosmotech_asset_data_layer_chart_repository" { default = "https://ghcr.io/cosmo-tech/cosmotech-asset-data-layer-api" }
variable "cosmotech_asset_data_layer_chart_name" { default = "cosmotech-asset-data-layer" }
variable "cosmotech_asset_data_layer_chart_tag" { default = "changeme" }
variable "cosmotech_asset_data_layer_image_registry" { default = "ghcr.io" }
variable "cosmotech_asset_data_layer_image_registry_auth_secret" { default = "registry-auth-ghcrio" }
variable "cosmotech_asset_data_layer_image_repository" { default = "cosmotech-asset-data-layer" }
variable "cosmotech_asset_data_layer_image_tag" { default = "changeme" }
variable "cosmotech_asset_data_layer_storage_size" { default = 8 }


## Cosmo Tech Asset Investment Planning API
variable "cosmotech_asset_investment_planning_api_chart_repository" { default = "https://ghcr.io/cosmo-tech/cosmotech-asset-investment-planning-helm" }
variable "cosmotech_asset_investment_planning_api_chart_name" { default = "cosmotech-asset-investment-planning" }
variable "cosmotech_asset_investment_planning_api_chart_tag" { default = "0.2.0" }
variable "cosmotech_asset_investment_planning_api_image_registry" { default = "ghcr.io" }
variable "cosmotech_asset_investment_planning_api_image_registry_auth_secret" { default = "registry-auth-ghcrio" }
variable "cosmotech_asset_investment_planning_api_image_repository" { default = "cosmo-tech/cosmotech-asset-investment-planning-api" }
variable "cosmotech_asset_investment_planning_api_image_tag" { default = "release-v0.4.0-dev1" }
variable "cosmotech_asset_investment_planning_api_storage_size" { default = 8 }


## Cosmo Tech Asset Investment Planning Webapp
variable "cosmotech_asset_investment_planning_webapp_chart_repository" { default = "https://ghcr.io/cosmo-tech/cosmotech-asset-investment-planning-helm" }
variable "cosmotech_asset_investment_planning_webapp_chart_name" { default = "cosmotech-asset-investment-planning" }
variable "cosmotech_asset_investment_planning_webapp_chart_tag" { default = "0.2.0" }
variable "cosmotech_asset_investment_planning_webapp_image_registry" { default = "ghcr.io" }
variable "cosmotech_asset_investment_planning_webapp_image_registry_auth_secret" { default = "registry-auth-ghcrio" }
variable "cosmotech_asset_investment_planning_webapp_image_repository" { default = "cosmo-tech/asset-investment-planning-webapp/webapp-server" }
variable "cosmotech_asset_investment_planning_webapp_image_tag" { default = "qa-v0.1" }


# Global
locals {
  module_storage_onprem_tag = "main"
  module_storage_azure_tag  = "main"
  module_storage_aws_tag    = "main"
  module_storage_gcp_tag    = "main"
}
