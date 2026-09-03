locals {
  tenant_namespace = "tenant-${var.tenant}"

  cluster_domain = "${var.cluster_name}.${var.domain_zone}"

  storage_class_name = "cosmotech-retain"
  persistences = {
    postgresql = {
      module     = "postgresql_cnpg_cluster"
      size       = var.postgresql_storage_size
      main_name  = "${var.cluster_name}-${local.tenant_namespace}-postgresql"
      pvc_name   = "${local.tenant_namespace}-postgresql-1"
      create_pvc = false
    }
    seaweedfs-master = {
      module     = "chart_seaweedfs"
      size       = 32
      main_name  = "${var.cluster_name}-${local.tenant_namespace}-seaweedfs-master"
      pvc_name   = "pvc-${local.tenant_namespace}-seaweedfs-master"
      create_pvc = true
    }
    seaweedfs-volume = {
      module     = "chart_seaweedfs"
      size       = var.seaweedfs_storage_size
      main_name  = "${var.cluster_name}-${local.tenant_namespace}-seaweedfs-volume"
      pvc_name   = "pvc-${local.tenant_namespace}-seaweedfs-volume"
      create_pvc = true
    }
    redis-master = {
      module     = "chart_redis"
      size       = var.redis_storage_size
      main_name  = "${var.cluster_name}-${local.tenant_namespace}-redis-master"
      pvc_name   = "pvc-${local.tenant_namespace}-redis-master"
      create_pvc = true
    }
    redis-replica = {
      module     = "chart_redis"
      size       = var.redis_storage_size
      main_name  = "${var.cluster_name}-${local.tenant_namespace}-redis-replica"
      pvc_name   = "pvc-${local.tenant_namespace}-redis-replica"
      create_pvc = true
    }
    cosmotech-asset-data-layer = {
      module     = "chart_cosmotech_asset_data_layer"
      size       = var.cosmotech_asset_data_layer_storage_size
      main_name  = "${var.cluster_name}-${local.tenant_namespace}-cosmotech-asset-data-layer"
      pvc_name   = "pvc-${var.cluster_name}-${local.tenant_namespace}-cosmotech-asset-data-layer"
      create_pvc = true
    }
    cosmotech-modeling-api = {
      module     = "chart_cosmotech_modeling_api"
      size       = var.cosmotech_modeling_api_storage_size
      main_name  = "${var.cluster_name}-${local.tenant_namespace}-cosmotech-modeling-api"
      pvc_name   = "pvc-${var.cluster_name}-${local.tenant_namespace}-cosmotech-modeling-api"
      create_pvc = true
    }
  }

  # Keep only the persistences required for the current tenant type
  tenant_recipe_persistences = {
    for k, v in local.persistences : k => v
    if contains(local.tenant_recipe_modules, v.module)
  }

  internal_postgresql_database = "cosmotech"
}


module "kube_namespace" {
  source = "./modules/kube_namespace"

  tenant_namespace = local.tenant_namespace
  tenant_type      = var.tenant_type

  use_external_postgresql = var.use_external_postgresql
}


module "config_keycloak_realm" {
  count  = contains(local.tenant_recipe_modules, "config_keycloak_realm") ? 1 : 0
  source = "./modules/config_keycloak_realm"

  tenant         = local.tenant_namespace
  cluster_domain = local.cluster_domain
}


# Timer to wait for storage to be created before continue.
# Also used a general gateway before install next modules.
resource "time_sleep" "timer" {
  create_duration = "30s"

  depends_on = [
    module.storage,
  ]
}


module "postgresql_cnpg_cluster" {
  count  = contains(local.tenant_recipe_modules, "postgresql_cnpg_cluster") ? 1 : 0
  source = "./modules/postgresql_cnpg_cluster"

  tenant = local.tenant_namespace

  image_registry             = var.postgresql_image_registry
  image_registry_auth_secret = var.postgresql_image_registry_auth_secret
  image_repository           = var.postgresql_image_repository
  image_tag                  = var.postgresql_image_tag

  size              = local.persistences.postgresql["size"]
  pvc               = local.persistences.postgresql["pvc_name"]
  pvc_storage_class = local.storage_class_name

  postgresql_image_repository = var.postgresql_image_repository
  postgresql_image_tag        = var.postgresql_image_tag

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_seaweedfs" {
  count  = contains(local.tenant_recipe_modules, "chart_seaweedfs") ? 1 : 0
  source = "./modules/chart_seaweedfs"

  tenant = local.tenant_namespace

  chart_repository = var.seaweedfs_chart_repository
  chart_name       = var.seaweedfs_chart_name
  chart_tag        = var.seaweedfs_chart_tag
  chart_release    = "seaweedfs"

  image_registry                           = var.seaweedfs_image_registry
  image_registry_auth_secret               = var.seaweedfs_image_registry_auth_secret
  seaweedfs_image_repository               = var.seaweedfs_image_repository
  seaweedfs_image_tag                      = var.seaweedfs_image_tag
  generic_shell_image_registry             = var.generic_shell_image_registry
  generic_shell_image_registry_auth_secret = var.generic_shell_image_registry_auth_secret
  generic_shell_image_repository           = var.generic_shell_image_repository
  generic_shell_image_tag                  = var.generic_shell_image_tag

  size_master              = local.persistences.seaweedfs-master["size"]
  pvc_master               = local.persistences.seaweedfs-master["pvc_name"]
  pvc_master_access_modes  = "ReadWriteOnce"
  pvc_master_storage_class = local.storage_class_name

  size_volume              = local.persistences.seaweedfs-volume["size"]
  pvc_volume               = local.persistences.seaweedfs-volume["pvc_name"]
  pvc_volume_access_modes  = "ReadWriteOnce"
  pvc_volume_storage_class = local.storage_class_name

  database_host = try(one(module.postgresql_cnpg_cluster[*].database_host), null)
  database_port = try(one(module.postgresql_cnpg_cluster[*].database_port), null)

  postgresql_image_repository = var.postgresql_image_repository
  postgresql_image_tag        = var.postgresql_image_tag

  depends_on = [
    time_sleep.timer,
    module.postgresql_cnpg_cluster,
  ]
}


module "chart_argo" {
  count  = contains(local.tenant_recipe_modules, "chart_argo") ? 1 : 0
  source = "./modules/chart_argo"

  tenant = local.tenant_namespace

  chart_repository = var.argo_chart_repository
  chart_name       = var.argo_chart_name
  chart_tag        = var.argo_chart_tag
  chart_release    = "argo-workflows"

  image_registry             = var.argo_image_registry
  image_registry_auth_secret = var.argo_image_registry_auth_secret
  # image_repository           = var.argo_image_repository
  image_tag = var.argo_image_tag

  database_host   = try(one(module.postgresql_cnpg_cluster[*].database_host), null)
  database_port   = try(one(module.postgresql_cnpg_cluster[*].database_port), null)
  database_name   = try(one(module.postgresql_cnpg_cluster[*].database_argo_name), null)
  database_user   = try(one(module.postgresql_cnpg_cluster[*].database_argo_user), null)
  database_secret = try(one(module.postgresql_cnpg_cluster[*].database_argo_secret), null)

  s3_host                = try(one(module.chart_seaweedfs[*].s3_host), null)
  s3_port                = try(one(module.chart_seaweedfs[*].s3_port), null)
  s3_bucket              = try(one(module.chart_seaweedfs[*].s3_argo_workflows_bucket), null)
  s3_secret              = try(one(module.chart_seaweedfs[*].s3_secret), null)
  s3_secret_key_username = try(one(module.chart_seaweedfs[*].s3_secret_key_argo_workflows_username), null)
  s3_secret_key_password = try(one(module.chart_seaweedfs[*].s3_secret_key_argo_workflows_password), null)

  postgresql_image_repository = var.postgresql_image_repository
  postgresql_image_tag        = var.postgresql_image_tag

  depends_on = [
    time_sleep.timer,
    module.postgresql_cnpg_cluster,
  ]
}


module "chart_redis" {
  count  = contains(local.tenant_recipe_modules, "chart_redis") ? 1 : 0
  source = "./modules/chart_redis"

  tenant = local.tenant_namespace

  chart_repository = var.redis_chart_repository
  chart_name       = var.redis_chart_name
  chart_tag        = var.redis_chart_tag
  chart_release    = "redis"

  image_registry             = var.redis_image_registry
  image_registry_auth_secret = var.redis_image_registry_auth_secret
  image_repository           = var.redis_image_repository
  image_tag                  = var.redis_image_tag

  size_master              = local.persistences.redis-master["size"]
  pvc_master               = local.persistences.redis-master["pvc_name"]
  pvc_master_storage_class = local.storage_class_name

  size_replica              = local.persistences.redis-replica["size"]
  pvc_replica               = local.persistences.redis-replica["pvc_name"]
  pvc_replica_storage_class = local.storage_class_name

  redis_image_repository = var.redis_image_repository
  redis_image_tag        = var.redis_image_tag

  generic_shell_image_repository = var.generic_shell_image_repository
  generic_shell_image_tag        = var.generic_shell_image_tag

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_cosmotech_run_api" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_run_api") ? 1 : 0
  source = "./modules/chart_cosmotech_run_api"

  tenant = local.tenant_namespace

  chart_repository = var.cosmotech_running_api_chart_repository
  chart_name       = var.cosmotech_running_api_chart_name
  chart_tag        = var.cosmotech_running_api_chart_tag
  chart_release    = "cosmotech-running-api"

  image_registry             = var.cosmotech_running_api_image_registry
  image_registry_auth_secret = var.cosmotech_running_api_image_registry_auth_secret
  image_repository           = var.cosmotech_running_api_image_repository
  image_tag                  = var.cosmotech_running_api_image_tag

  use_external_postgresql      = var.use_external_postgresql
  external_postgresql_host     = var.external_postgresql_host
  external_postgresql_port     = var.external_postgresql_port
  external_postgresql_username = var.external_postgresql_username
  external_postgresql_password = var.external_postgresql_password

  internal_postgresql_host             = try(one(module.postgresql_cnpg_cluster[*].database_host), null)
  internal_postgresql_port             = try(one(module.postgresql_cnpg_cluster[*].database_port), null)
  internal_postgresql_image_repository = var.postgresql_image_repository
  internal_postgresql_image_tag        = var.postgresql_image_tag

  s3_host                = try(one(module.chart_seaweedfs[*].s3_host), null)
  s3_port                = try(one(module.chart_seaweedfs[*].s3_port), null)
  s3_bucket              = try(one(module.chart_seaweedfs[*].s3_cosmotech_api_bucket), null)
  s3_secret              = try(one(module.chart_seaweedfs[*].s3_secret), null)
  s3_secret_key_username = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_username), null)
  s3_secret_key_password = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_password), null)

  cluster_domain = local.cluster_domain

  keycloak_client_id     = try(one(module.config_keycloak_realm[*].keycloak_api_client_id), null)
  keycloak_client_secret = try(one(module.config_keycloak_realm[*].keycloak_api_client_secret), null)

  depends_on = [
    time_sleep.timer,
    module.chart_redis,
    module.chart_argo,
    module.config_harbor_project,
    module.config_keycloak_realm,
  ]
}


module "chart_cosmotech_modeling_api" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_modeling_api") ? 1 : 0
  source = "./modules/chart_cosmotech_modeling_api"

  tenant = local.tenant_namespace

  chart_repository = var.cosmotech_modeling_api_chart_repository
  chart_name       = var.cosmotech_modeling_api_chart_name
  chart_tag        = var.cosmotech_modeling_api_chart_tag
  chart_release    = "cosmotech-modeling-api"

  image_registry             = var.cosmotech_modeling_api_image_registry
  image_registry_auth_secret = var.cosmotech_modeling_api_image_repository
  image_repository           = var.cosmotech_modeling_api_image_repository
  image_tag                  = var.cosmotech_modeling_api_image_tag

  pvc = local.persistences.cosmotech-modeling-api["pvc_name"]

  s3_host                = try(one(module.chart_seaweedfs[*].s3_host), null)
  s3_port                = try(one(module.chart_seaweedfs[*].s3_port), null)
  s3_bucket              = try(one(module.chart_seaweedfs[*].s3_argo_workflows_bucket), null)
  s3_secret              = try(one(module.chart_seaweedfs[*].s3_secret), null)
  s3_secret_key_username = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_username), null)
  s3_secret_key_password = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_password), null)


  cluster_domain = local.cluster_domain

  depends_on = [
    time_sleep.timer,
    module.chart_argo,
    module.chart_seaweedfs,
  ]
}


module "chart_cosmotech_asset_data_layer" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_asset_data_layer") ? 1 : 0
  source = "./modules/chart_cosmotech_asset_data_layer"

  tenant = local.tenant_namespace

  chart_repository = var.cosmotech_asset_data_layer_chart_repository
  chart_name       = var.cosmotech_asset_data_layer_chart_name
  chart_tag        = var.cosmotech_asset_data_layer_chart_tag
  chart_release    = "cosmotech-asset-data-layer"

  image_registry             = var.cosmotech_asset_data_layer_image_registry
  image_registry_auth_secret = var.cosmotech_asset_data_layer_image_repository
  image_repository           = var.cosmotech_asset_data_layer_image_repository
  image_tag                  = var.cosmotech_asset_data_layer_image_tag

  persistence_size  = local.persistences.cosmotech-asset-data-layer["size"]
  persistence_pvc   = local.persistences.cosmotech-asset-data-layer["pvc_name"]
  pvc_storage_class = local.storage_class_name

  postgresql_host     = var.use_external_postgresql == true ? var.external_postgresql_host : try(one(module.postgresql_cnpg_cluster[*].database_host), null)
  postgresql_port     = var.use_external_postgresql == true ? var.external_postgresql_port : try(one(module.postgresql_cnpg_cluster[*].database_port), null)
  postgresql_database = var.use_external_postgresql == true ? local.tenant_namespace : local.internal_postgresql_database

  # s3_host                = try(one(module.chart_seaweedfs[*].s3_host), null)
  # s3_port                = try(one(module.chart_seaweedfs[*].s3_port), null)
  # s3_bucket              = try(one(module.chart_seaweedfs[*].s3_cosmotech_api_bucket), null)
  # s3_secret_key_username = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_username), null)
  # s3_secret_key_password = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_password), null)

  cluster_domain = local.cluster_domain

  keycloak_client_id = try(one(module.config_keycloak_realm[*].keycloak_api_client_id), null)

  cosmotech_api_client_id     = try(one(module.config_keycloak_realm[*].keycloak_api_client_id), null)
  cosmotech_api_client_secret = try(one(module.config_keycloak_realm[*].keycloak_api_client_secret), null)

  depends_on = [
    time_sleep.timer,
    module.chart_cosmotech_run_api,
    module.config_keycloak_realm,
  ]
}


module "chart_cosmotech_asset_investment_planning_api" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_asset_investment_planning_api") ? 1 : 0
  source = "./modules/chart_cosmotech_asset_investment_planning_api"

  tenant = local.tenant_namespace

  chart_repository = var.cosmotech_asset_investment_planning_api_chart_repository
  chart_name       = var.cosmotech_asset_investment_planning_api_chart_name
  chart_tag        = var.cosmotech_asset_investment_planning_api_chart_tag
  chart_release    = "cosmotech-asset-investment-planning-api"

  image_registry             = var.cosmotech_asset_investment_planning_api_image_registry
  image_registry_auth_secret = var.cosmotech_asset_investment_planning_api_image_repository
  image_repository           = var.cosmotech_asset_investment_planning_api_image_repository
  image_tag                  = var.cosmotech_asset_investment_planning_api_image_tag

  cluster_domain = local.cluster_domain

  postgresql_host     = var.use_external_postgresql == true ? var.external_postgresql_host : try(one(module.postgresql_cnpg_cluster[*].database_host), null)
  postgresql_port     = var.use_external_postgresql == true ? var.external_postgresql_port : try(one(module.postgresql_cnpg_cluster[*].database_port), null)
  postgresql_database = var.use_external_postgresql == true ? local.tenant_namespace : local.internal_postgresql_database

  depends_on = [
    time_sleep.timer,
    module.postgresql_cnpg_cluster,
    module.config_keycloak_realm,
  ]
}


module "chart_cosmotech_asset_investment_planning_webapp" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_asset_investment_planning_webapp") ? 1 : 0
  source = "./modules/chart_cosmotech_asset_investment_planning_webapp"

  tenant = local.tenant_namespace

  chart_repository = var.cosmotech_asset_investment_planning_webapp_chart_repository
  chart_name       = var.cosmotech_asset_investment_planning_webapp_chart_name
  chart_tag        = var.cosmotech_asset_investment_planning_webapp_chart_tag
  chart_release    = "cosmotech-asset-investment-planning-webapp"

  image_registry             = var.cosmotech_asset_investment_planning_webapp_image_registry
  image_registry_auth_secret = var.cosmotech_asset_investment_planning_webapp_image_repository
  image_repository           = var.cosmotech_asset_investment_planning_webapp_image_repository
  image_tag                  = var.cosmotech_asset_investment_planning_webapp_image_tag

  cluster_domain = local.cluster_domain

  keycloak_client_id = try(one(module.config_keycloak_realm[*].keycloak_api_client_id), null)

  depends_on = [
    time_sleep.timer,
    module.chart_cosmotech_asset_investment_planning_api,
  ]
}


module "config_grafana_dashboard" {
  count  = contains(local.tenant_recipe_modules, "config_grafana_dashboard") ? 1 : 0
  source = "./modules/config_grafana_dashboard"

  tenant         = local.tenant_namespace
  cluster_domain = local.cluster_domain
  secret_redis   = try(one(module.chart_redis[*].redis_secret), null)

  depends_on = [
    module.chart_cosmotech_run_api
  ]
}


module "config_harbor_project" {
  count  = contains(local.tenant_recipe_modules, "config_harbor_project") ? 1 : 0
  source = "./modules/config_harbor_project"

  tenant         = local.tenant_namespace
  cluster_domain = local.cluster_domain
}


module "config_superset_oauth_provider" {
  count  = contains(local.tenant_recipe_modules, "config_superset_oauth_provider") ? 1 : 0
  source = "./modules/config_superset_oauth_provider"

  tenant         = local.tenant_namespace
  cluster_domain = local.cluster_domain

  depends_on = [
    module.config_keycloak_realm
  ]
}
