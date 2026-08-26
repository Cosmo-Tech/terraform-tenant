locals {
  tenant_namespace_raw = "tenant-${var.tenant}"
  tenant_namespace     = var.use_external_postgresql ? "${local.tenant_namespace_raw}-extdb" : local.tenant_namespace_raw

  cluster_domain = "${var.cluster_name}.${var.domain_zone}"

  # Fall back to a computed hostname (based on the cluster name) when
  # var.external_postgres_host is not explicitly set in tfvars.
  external_postgres_host = coalesce(var.external_postgres_host, "csm-${var.cluster_name}.postgres.database.azure.com")

  storage_class_name = "cosmotech-retain"
  persistences = {
    postgresql = {
      module     = "postgresql"
      size       = var.postgresql_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant_namespace}-postgresql"
      pvc_name   = "${module.kube_namespace.tenant_namespace}-postgresql-1"
      create_pvc = false
    }
    seaweedfs-master = {
      module     = "chart_seaweedfs"
      size       = 32
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant_namespace}-seaweedfs-master"
      pvc_name   = "pvc-${module.kube_namespace.tenant_namespace}-seaweedfs-master"
      create_pvc = true
    }
    seaweedfs-volume = {
      module     = "chart_seaweedfs"
      size       = var.seaweedfs_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant_namespace}-seaweedfs-volume"
      pvc_name   = "pvc-${module.kube_namespace.tenant_namespace}-seaweedfs-volume"
      create_pvc = true
    }
    redis-master = {
      module     = "chart_redis"
      size       = var.redis_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant_namespace}-redis-master"
      pvc_name   = "pvc-${module.kube_namespace.tenant_namespace}-redis-master"
      create_pvc = true
    }
    redis-replica = {
      module     = "chart_redis"
      size       = var.redis_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant_namespace}-redis-replica"
      pvc_name   = "pvc-${module.kube_namespace.tenant_namespace}-redis-replica"
      create_pvc = true
    }
    cosmotech-asset-data-layer = {
      module     = "chart_cosmotech_asset_data_layer"
      size       = var.cosmotech_asset_data_layer_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant_namespace}-cosmotech-asset-data-layer"
      pvc_name   = "pvc-${var.cluster_name}-${module.kube_namespace.tenant_namespace}-cosmotech-asset-data-layer"
      create_pvc = true
    }
    cosmotech-modeling-api = {
      module     = "chart_cosmotech_modeling_api"
      size       = var.cosmotech_modeling_api_storage_size
      main_name  = "${var.cluster_name}-${module.kube_namespace.tenant_namespace}-cosmotech-modeling-api"
      pvc_name   = "pvc-${var.cluster_name}-${module.kube_namespace.tenant_namespace}-cosmotech-modeling-api"
      create_pvc = true
    }
  }

  # Keep only the persistences required for the current tenant type
  tenant_recipe_persistences = {
    for k, v in local.persistences : k => v
    if contains(local.tenant_recipe_modules, v.module)
  }

  image_registry = module.kube_namespace.image_registry

  # Cosmo Tech API database connection info: either the external PostgreSQL
  # server or the in-cluster PostgreSQL chart, depending on var.use_external_postgres.
  cosmotech_api_db = var.use_external_postgres ? {
    host            = module.postgresql_external[0].database_host
    port            = tostring(module.postgresql_external[0].database_port)
    database        = module.postgresql_external[0].database_name
    admin_username  = module.postgresql_external[0].admin_username
    writer_username = module.postgresql_external[0].writer_username
    reader_username = module.postgresql_external[0].reader_username
    } : {
    host            = module.chart_postgresql.database_host
    port            = module.chart_postgresql.database_port
    database        = module.chart_postgresql.database_cosmotech_name
    admin_username  = module.chart_postgresql.database_cosmotech_username_admin
    writer_username = module.chart_postgresql.database_cosmotech_username_writer
    reader_username = module.chart_postgresql.database_cosmotech_username_reader
  }
}


module "kube_namespace" {
  source = "./modules/kube_namespace"

  tenant_namespace = local.tenant_namespace
  tenant_type      = var.tenant_type

  image_registry_auth_secret = var.image_registry_auth_secret
}


module "config_keycloak_realm" {
  count  = contains(local.tenant_recipe_modules, "config_keycloak_realm") ? 1 : 0
  source = "./modules/config_keycloak_realm"

  tenant         = module.kube_namespace.tenant_namespace
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

  tenant = module.kube_namespace.tenant_namespace

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  size              = local.persistences.postgresql["size"]
  pvc               = local.persistences.postgresql["pvc_name"]
  pvc_storage_class = local.storage_class_name

  postgresql_image_repository = var.postgresql_image_repository
  postgresql_image_tag        = var.postgresql_image_tag

  use_external_postgres = var.use_external_postgres

  depends_on = [
    time_sleep.timer,
  ]
}


# Reads the Cosmo Tech API credentials generated by the chart_postgresql
# module and declaratively provisions the roles/database/schema on the
# external PostgreSQL server (e.g. Azure PostgreSQL Flexible Server),
# replacing the legacy Bash/psql init Job when use_external_postgres = true.
module "postgresql_external" {
  source = "./modules/postgresql_external"
  count  = var.use_external_postgres ? 1 : 0

  tenant        = module.kube_namespace.tenant
  # tenant_prefix = var.tenant

  database_name = module.chart_postgresql.database_cosmotech_name

  postgresql_admin_password  = module.chart_postgresql.database_cosmotech_password_admin
  postgresql_writer_password = module.chart_postgresql.database_cosmotech_password_writer
  postgresql_reader_password = module.chart_postgresql.database_cosmotech_password_reader

  external_postgres_host = local.external_postgres_host
  external_postgres_port = var.external_postgres_port

  depends_on = [
    module.chart_postgresql,
  ]
}


module "chart_seaweedfs" {
  count  = contains(local.tenant_recipe_modules, "chart_seaweedfs") ? 1 : 0
  source = "./modules/chart_seaweedfs"

  tenant = module.kube_namespace.tenant_namespace

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

  database_host             = try(one(module.postgresql[*].database_host), null)
  database_port             = try(one(module.postgresql[*].database_port), null)
  database_seaweedfs_name   = try(one(module.postgresql[*].database_seaweedfs_name), null)
  database_seaweedfs_user   = try(one(module.postgresql[*].database_seaweedfs_user), null)
  database_seaweedfs_secret = try(one(module.postgresql[*].database_seaweedfs_secret), null)

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

  tenant = module.kube_namespace.tenant_namespace

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.argo_chart_repository
  chart_name       = var.argo_chart_name
  chart_tag        = var.argo_chart_tag
  chart_release    = "argo-workflows"

  database_host   = try(one(module.postgresql[*].database_host), null)
  database_port   = try(one(module.postgresql[*].database_port), null)
  database_name   = try(one(module.postgresql[*].database_argo_name), null)
  database_user   = try(one(module.postgresql[*].database_argo_user), null)
  database_secret = try(one(module.postgresql[*].database_argo_secret), null)

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

  tenant = module.kube_namespace.tenant_namespace

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

  tenant = module.kube_namespace.tenant_namespace

  # image_registry             = local.image_registry
  # image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.cosmotechapi_chart_repository
  chart_name       = var.cosmotechapi_chart_name
  chart_tag        = var.cosmotechapi_chart_tag
  chart_release    = "cosmotech-api"

  postgresql_host            = try(one(module.postgresql[*].database_host), null)
  postgresql_port            = try(one(module.postgresql[*].database_port), null)
  postgresql_database        = try(one(module.postgresql[*].database_cosmotech_name), null)
  postgresql_admin_username  = try(one(module.postgresql[*].database_cosmotech_username_admin), null)
  postgresql_admin_password  = try(one(module.postgresql[*].database_cosmotech_password_admin), null)
  postgresql_writer_username = try(one(module.postgresql[*].database_cosmotech_username_writer), null)
  postgresql_writer_password = try(one(module.postgresql[*].database_cosmotech_password_writer), null)
  postgresql_reader_username = try(one(module.postgresql[*].database_cosmotech_username_reader), null)
  postgresql_reader_password = try(one(module.postgresql[*].database_cosmotech_password_reader), null)

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
    module.postgresql_external,
  ]
}


module "chart_cosmotech_modeling_api" {
  count  = contains(local.tenant_recipe_modules, "chart_cosmotech_modeling_api") ? 1 : 0
  source = "./modules/chart_cosmotech_modeling_api"

  tenant = module.kube_namespace.tenant_namespace

  chart_repository = var.cosmotech_modeling_api_chart_repository
  chart_name       = var.cosmotech_modeling_api_chart_name
  chart_tag        = var.cosmotech_modeling_api_chart_tag
  chart_release    = "cosmotech-modeling-api"

  image_tag                  = var.cosmotech_modeling_api_image_tag
  image_registry_auth_secret = var.cosmotech_modeling_api_image_registry_auth_secret

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

  tenant = module.kube_namespace.tenant_namespace

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret
  image_tag                  = var.cosmotech_asset_data_layer_image_tag

  chart_repository = var.cosmotech_asset_data_layer_chart_repository
  chart_name       = var.cosmotech_asset_data_layer_chart_name
  chart_tag        = var.cosmotech_asset_data_layer_chart_tag
  chart_release    = "cosmotech-asset-data-layer"

  persistence_size              = local.persistences.cosmotech-asset-data-layer["size"]
  persistence_pvc               = local.persistences.cosmotech-asset-data-layer["pvc_name"]
  persistence_pvc_storage_class = local.storage_class_name

  postgresql_host     = try(one(module.postgresql[*].database_host), null)
  postgresql_port     = try(one(module.postgresql[*].database_port), null)
  postgresql_database = try(one(module.postgresql[*].database_cosmotech_name), null)
  postgresql_username = try(one(module.postgresql[*].database_cosmotech_username), null)
  postgresql_password = try(one(module.postgresql[*].database_cosmotech_password), null)

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

  tenant            = module.kube_namespace.tenant_namespace
  cluster_domain    = local.cluster_domain
  secret_redis      = try(one(module.chart_redis[*].redis_secret), null)
  secret_postgresql = try(one(module.postgresql[*].postgresql_secret), null)
}


module "config_harbor_project" {
  count  = contains(local.tenant_recipe_modules, "config_harbor_project") ? 1 : 0
  source = "./modules/config_harbor_project"

  tenant         = module.kube_namespace.tenant_namespace
  cluster_domain = local.cluster_domain
}


module "config_superset_oauth_provider" {
  count  = contains(local.tenant_recipe_modules, "config_superset_oauth_provider") ? 1 : 0
  source = "./modules/config_superset_oauth_provider"

  tenant         = module.kube_namespace.tenant_namespace
  cluster_domain = local.cluster_domain

  depends_on = [
    module.config_keycloak_realm
  ]
}
