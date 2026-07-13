# This file allows to fix defaults values, and also allow to override them from terraform.tfvars, CLI arguments or TF_VAR env variables.


# Registry
variable "image_registry_auth_secret" { default = "registry-auth-cgrdev" }


# PostgreSQL
variable "postgresql_chart_name" { default = "postgresql" }
variable "postgresql_chart_repository" { default = "oci://cgr.dev/cosmotech/iamguarded-charts" }
variable "postgresql_chart_tag" { default = "17.1.0" }
variable "postgresql_storage_size" { default = 8 }
variable "postgresql_image_repository" { default = "cosmotech/postgres-iamguarded" } # Note: not only used in postgresql module, but also in others modules to ensure psql is the same everywhere
variable "postgresql_image_tag" { default = "17" }                                   # Note: not only used in postgresql module, but also in others modules to ensure psql is the same everywhere


# SeaweedFS
variable "seaweedfs_chart_name" { default = "seaweedfs" }
variable "seaweedfs_chart_repository" { default = "oci://cgr.dev/cosmotech/iamguarded-charts" }
variable "seaweedfs_chart_tag" { default = "6.0.4" }
variable "seaweedfs_storage_size" { default = 32 }


# Argo Workflows
variable "argo_chart_name" { default = "argo-workflows" }
variable "argo_chart_repository" { default = "oci://cgr.dev/cosmotech/iamguarded-charts" }
variable "argo_chart_tag" { default = "13.0.6" }


# Redis
variable "redis_chart_name" { default = "redis" }
variable "redis_chart_repository" { default = "oci://cgr.dev/cosmotech/iamguarded-charts" }
variable "redis_chart_tag" { default = "25.3.8" }
variable "redis_storage_size" { default = 16 }
variable "redis_image_repository" { default = "cosmotech/redis-server-iamguarded" }
variable "redis_image_tag" { default = "8.6.3" }


# Cosmo Tech API
variable "cosmotechapi_chart_name" { default = "cosmotech-api" }
variable "cosmotechapi_chart_repository" { default = "https://cosmo-tech.github.io/helm-charts" }
variable "cosmotechapi_chart_tag" { default = "5.0.1" }


# Cosmo Tech Modeling API
variable "cosmotech_modeling_api_enabled" { default = false }
variable "cosmotech_modeling_api_chart_name" { default = "cosmotech-modeling-api" }
variable "cosmotech_modeling_api_chart_repository" { default = "https://cosmo-tech.github.io/helm-charts" }
variable "cosmotech_modeling_api_chart_tag" { default = "0.7.0" }
variable "cosmotech_modeling_api_image_tag" { default = "12.3.0" }
variable "cosmotech_modeling_api_image_registry_auth_secret" { default = "registry-auth-cosmotech-modeling-api" }
variable "cosmotech_modeling_api_storage_size" { default = 8 }
