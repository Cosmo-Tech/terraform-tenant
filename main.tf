locals {
  main_name_suffixes = {
    standard        = ""
    modeling        = "mod"
    asset           = "asset"
    asset_portfolio = "pfolio"
  }
  main_name_suffix              = lookup(local.main_name_suffixes, var.tenant_type, "")
  main_name_suffix_formatted    = local.main_name_suffix != "" ? "-${local.main_name_suffix}" : ""
  main_name_suffix_db_formatted = var.use_external_postgresql ? "-extdb" : ""
  main_name                     = "tenant-${var.tenant}${local.main_name_suffix_formatted}${local.main_name_suffix_db_formatted}"

  # main_name      = "tenant-${var.tenant}"
  cluster_domain = "${var.cluster_name}.${var.domain_zone}"

  storage_class_name = "cosmotech-retain"
  persistences = {
    postgresql = {
      namespace  = module.kube_namespace.tenant
      size       = var.postgresql_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant}-postgresql"
      pvc_name   = "${module.kube_namespace.tenant}-postgresql-1"
      create_pvc = false
    }
    seaweedfs-master = {
      namespace  = module.kube_namespace.tenant
      size       = 32
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant}-seaweedfs-master"
      pvc_name   = "pvc-${module.kube_namespace.tenant}-seaweedfs-master"
      create_pvc = true
    }
    seaweedfs-volume = {
      namespace  = module.kube_namespace.tenant
      size       = var.seaweedfs_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant}-seaweedfs-volume"
      pvc_name   = "pvc-${module.kube_namespace.tenant}-seaweedfs-volume"
      create_pvc = true
    }
    redis-master = {
      namespace  = module.kube_namespace.tenant
      size       = var.redis_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant}-redis-master"
      pvc_name   = "pvc-${module.kube_namespace.tenant}-redis-master"
      create_pvc = true
    }
    redis-replica = {
      namespace  = module.kube_namespace.tenant
      size       = var.redis_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant}-redis-replica"
      pvc_name   = "pvc-${module.kube_namespace.tenant}-redis-replica"
      create_pvc = true
    }
    cosmotech-asset-data-layer = {
      module = "chart_cosmotech_asset_data_layer"
      size   = var.cosmotech_asset_data_layer_storage_size
      name   = "${var.cluster_name}-${module.kube_namespace.tenant}-cosmotech-asset-data-layer"
    }
  }

  # Keep only the persistences required for the current tenant type
  tenant_recipe_persistences = {
    for k, v in local.persistences : k => v
    if contains(local.tenant_recipe_modules, v.module)
  }

  image_registry = module.kube_namespace.image_registry
}


module "kube_namespace" {
  source = "./modules/kube_namespace"

  tenant = var.tenant

  image_registry_auth_secret = var.image_registry_auth_secret
}


module "config_keycloak_realm" {
  count  = contains(local.tenant_recipe_modules, "config_keycloak_realm") ? 1 : 0
  source = "./modules/config_keycloak_realm"

  tenant         = module.kube_namespace.tenant
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


module "postgresql" {
  source = "./modules/postgresql"

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

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

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.seaweedfs_chart_repository
  chart_name       = var.seaweedfs_chart_name
  chart_tag        = var.seaweedfs_chart_tag
  chart_release    = "seaweedfs"

  size_master              = local.persistences.seaweedfs-master["size"]
  pvc_master               = local.persistences.seaweedfs-master["pvc_name"]
  pvc_master_access_modes  = "ReadWriteOnce"
  pvc_master_storage_class = local.storage_class_name

  size_volume              = local.persistences.seaweedfs-volume["size"]
  pvc_volume               = local.persistences.seaweedfs-volume["pvc_name"]
  pvc_volume_access_modes  = "ReadWriteOnce"
  pvc_volume_storage_class = local.storage_class_name

  database_host             = try(one(module.chart_postgresql[*].database_host), null)
  database_port             = try(one(module.chart_postgresql[*].database_port), null)
  database_seaweedfs_name   = try(one(module.chart_postgresql[*].database_seaweedfs_name), null)
  database_seaweedfs_user   = try(one(module.chart_postgresql[*].database_seaweedfs_user), null)
  database_seaweedfs_secret = try(one(module.chart_postgresql[*].database_seaweedfs_secret), null)

  postgresql_image_repository = var.postgresql_image_repository
  postgresql_image_tag        = var.postgresql_image_tag

  depends_on = [
    time_sleep.timer,
    module.postgresql,
  ]
}


module "chart_argo" {
  count  = contains(local.tenant_recipe_modules, "chart_argo") ? 1 : 0
  source = "./modules/chart_argo"

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.argo_chart_repository
  chart_name       = var.argo_chart_name
  chart_tag        = var.argo_chart_tag
  chart_release    = "argo-workflows"

  database_host   = try(one(module.chart_postgresql[*].database_host), null)
  database_port   = try(one(module.chart_postgresql[*].database_port), null)
  database_name   = try(one(module.chart_postgresql[*].database_argo_name), null)
  database_user   = try(one(module.chart_postgresql[*].database_argo_user), null)
  database_secret = try(one(module.chart_postgresql[*].database_argo_secret), null)

  s3_host                = try(one(module.chart_seaweedfs[*].s3_host), null)
  s3_port                = try(one(module.chart_seaweedfs[*].s3_port), null)
  s3_bucket              = try(one(module.chart_seaweedfs[*].s3_argo_workflows_bucket), null)
  s3_secret              = try(one(module.chart_seaweedfs[*].s3_secret), null)
  s3_secret_key_username = try(one(module.chart_seaweedfs[*].s3_secret_key_argo_workflows_username), null)
  s3_secret_key_password = try(one(module.chart_seaweedfs[*].s3_secret_key_argo_workflows_password), null)

  depends_on = [
    time_sleep.timer,
    module.postgresql,
  ]
}


module "chart_redis" {
  count  = contains(local.tenant_recipe_modules, "chart_redis") ? 1 : 0
  source = "./modules/chart_redis"

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.redis_chart_repository
  chart_name       = var.redis_chart_name
  chart_tag        = var.redis_chart_tag
  chart_release    = "redis"

  size_master              = local.persistences.redis-master["size"]
  pvc_master               = local.persistences.redis-master["pvc_name"]
  pvc_master_storage_class = local.storage_class_name

  size_replica              = local.persistences.redis-replica["size"]
  pvc_replica               = local.persistences.redis-replica["pvc_name"]
  pvc_replica_storage_class = local.storage_class_name

  redis_image_repository = var.redis_image_repository
  redis_image_tag        = var.redis_image_tag

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_cosmotech_api" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_api") ? 1 : 0
  source = "./modules/chart_cosmotech_api"

  tenant = module.kube_namespace.tenant

  # image_registry             = local.image_registry
  # image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.cosmotechapi_chart_repository
  chart_name       = var.cosmotechapi_chart_name
  chart_tag        = var.cosmotechapi_chart_tag
  chart_release    = "cosmotech-api"

  postgresql_host            = try(one(module.chart_postgresql[*].database_host), null)
  postgresql_port            = try(one(module.chart_postgresql[*].database_port), null)
  postgresql_database        = try(one(module.chart_postgresql[*].database_cosmotech_name), null)
  postgresql_admin_username  = try(one(module.chart_postgresql[*].database_cosmotech_username_admin), null)
  postgresql_admin_password  = try(one(module.chart_postgresql[*].database_cosmotech_password_admin), null)
  postgresql_writer_username = try(one(module.chart_postgresql[*].database_cosmotech_username_writer), null)
  postgresql_writer_password = try(one(module.chart_postgresql[*].database_cosmotech_password_writer), null)
  postgresql_reader_username = try(one(module.chart_postgresql[*].database_cosmotech_username_reader), null)
  postgresql_reader_password = try(one(module.chart_postgresql[*].database_cosmotech_password_reader), null)

  s3_host                = try(one(module.chart_seaweedfs[*].s3_host), null)
  s3_port                = try(one(module.chart_seaweedfs[*].s3_port), null)
  s3_bucket              = try(one(module.chart_seaweedfs[*].s3_cosmotech_api_bucket), null)
  s3_secret              = try(one(module.chart_seaweedfs[*].s3_secret), null)
  s3_secret_key_username = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_username), null)
  s3_secret_key_password = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_password), null)

  cluster_domain = local.cluster_domain

  keycloak_client_id     = try(one(module.config_keycloak_realm[*].keycloak_api_client_id), null)
  keycloak_client_secret = try(one(module.config_keycloak_realm[*].keycloak_api_client_secret), null)

  ## Ingress Nginx
  # cosmotech_api_connect_timeout = "30s"
  # cosmotech_api_query_timeout   = "60s"
  # cosmotech_api_buffer_size     = "16K"
  # cosmotech_api_max_file_size   = "300m"

  depends_on = [
    time_sleep.timer,
    module.postgresql,
    module.chart_redis,
    module.chart_argo,
    module.config_harbor_project,
    module.config_keycloak_realm,
  ]
}


module "chart_cosmotech_modeling_api" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_modeling_api") ? 1 : 0
  source = "./modules/chart_cosmotech_modeling_api"

  tenant = module.kube_namespace.tenant

  chart_repository = var.cosmotech_modeling_api_chart_repository
  chart_name       = var.cosmotech_modeling_api_chart_name
  chart_tag        = var.cosmotech_modeling_api_chart_tag
  chart_release    = "cosmotech-modeling-api"

  image_tag                  = var.cosmotech_modeling_api_image_tag
  image_registry_auth_secret = var.cosmotech_modeling_api_image_registry_auth_secret

  pvc = "pvc-${local.persistences.cosmotech-modeling-api["name"]}"

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

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret
  image_tag                  = var.cosmotech_asset_data_layer_image_tag

  chart_repository = var.cosmotech_asset_data_layer_chart_repository
  chart_name       = var.cosmotech_asset_data_layer_chart_name
  chart_tag        = var.cosmotech_asset_data_layer_chart_tag
  chart_release    = "cosmotech-asset-data-layer"

  persistence_size              = local.persistences.cosmotech-asset-data-layer["size"]
  persistence_pvc               = "pvc-${local.persistences.cosmotech-asset-data-layer["name"]}"
  persistence_pvc_storage_class = local.storage_class_name

  postgresql_host     = try(one(module.chart_postgresql[*].database_host), null)
  postgresql_port     = try(one(module.chart_postgresql[*].database_port), null)
  postgresql_database = try(one(module.chart_postgresql[*].database_cosmotech_name), null)
  postgresql_username = try(one(module.chart_postgresql[*].database_cosmotech_username), null)
  postgresql_password = try(one(module.chart_postgresql[*].database_cosmotech_password), null)

  s3_host   = try(one(module.chart_seaweedfs[*].s3_host), null)
  s3_port   = try(one(module.chart_seaweedfs[*].s3_port), null)
  s3_bucket = try(one(module.chart_seaweedfs[*].s3_cosmotech_api_bucket), null)
  # s3_secret              = try(one(module.chart_seaweedfs[*].s3_secret), null)
  s3_secret_key_username = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_username), null)
  s3_secret_key_password = try(one(module.chart_seaweedfs[*].s3_secret_key_cosmotech_api_password), null)

  cluster_domain = local.cluster_domain

  keycloak_client_id = try(one(module.config_keycloak_realm[*].keycloak_api_client_id), null)
  # keycloak_client_secret = try(one(module.config_keycloak_realm[*].keycloak_api_client_secret), null)


  cosmotech_api_client_id     = try(one(module.config_keycloak_realm[*].keycloak_api_client_id), null)
  cosmotech_api_client_secret = try(one(module.config_keycloak_realm[*].keycloak_api_client_secret), null)

  # harbor_password = 


  depends_on = [
    time_sleep.timer,
    module.chart_cosmotech_api,
  ]
}


module "config_grafana_dashboard" {
  count  = contains(local.tenant_recipe_modules, "config_grafana_dashboard") ? 1 : 0
  source = "./modules/config_grafana_dashboard"

  tenant            = module.kube_namespace.tenant
  cluster_domain    = local.cluster_domain
  secret_redis      = try(one(module.chart_redis[*].redis_secret), null)
  secret_postgresql = try(one(module.chart_postgresql[*].postgresql_secret), null)
}


module "config_harbor_project" {
  count  = contains(local.tenant_recipe_modules, "config_harbor_project") ? 1 : 0
  source = "./modules/config_harbor_project"

  tenant         = module.kube_namespace.tenant
  cluster_domain = local.cluster_domain
}


module "config_superset_oauth_provider" {
  count  = contains(local.tenant_recipe_modules, "config_superset_oauth_provider") ? 1 : 0
  source = "./modules/config_superset_oauth_provider"

  tenant         = module.kube_namespace.tenant
  cluster_domain = local.cluster_domain

  depends_on = [
    module.config_keycloak_realm
  ]
}
