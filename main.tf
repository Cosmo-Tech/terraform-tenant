locals {
  main_name      = "tenant-${var.tenant}"
  cluster_domain = "${var.cluster_name}.${var.domain_zone}"

  storage_class_name = "cosmotech-retain"
  persistences = {
    postgresql = {
      size = var.postgresql_storage_size
      name = "${var.cluster_name}-${module.kube_namespace.tenant}-postgresql"
    }
    seaweedfs-master = {
      size = 32
      name = "${var.cluster_name}-${module.kube_namespace.tenant}-seaweedfs-master"
    }
    seaweedfs-volume = {
      size = var.seaweedfs_storage_size
      name = "${var.cluster_name}-${module.kube_namespace.tenant}-seaweedfs-volume"
    }
    redis-master = {
      size = var.redis_storage_size
      name = "${var.cluster_name}-${module.kube_namespace.tenant}-redis-master"
    }
    redis-replica = {
      size = var.redis_storage_size
      name = "${var.cluster_name}-${module.kube_namespace.tenant}-redis-replica"
    }
  }

  image_registry = module.kube_namespace.image_registry
}


module "kube_namespace" {
  source = "./modules/kube_namespace"

  tenant = var.tenant

  image_registry_auth_secret = var.image_registry_auth_secret
}


module "config_keycloak_realm" {
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


module "chart_postgresql" {
  source = "./modules/chart_postgresql"

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.postgresql_chart_repository
  chart_name       = var.postgresql_chart_name
  chart_tag        = var.postgresql_chart_tag
  chart_release    = "postgresql"

  size              = local.persistences.postgresql["size"]
  pvc               = "pvc-${local.persistences.postgresql["name"]}"
  pvc_storage_class = local.storage_class_name

  postgresql_image_repository = var.postgresql_image_repository
  postgresql_image_tag        = var.postgresql_image_tag

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_seaweedfs" {
  source = "./modules/chart_seaweedfs"

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.seaweedfs_chart_repository
  chart_name       = var.seaweedfs_chart_name
  chart_tag        = var.seaweedfs_chart_tag
  chart_release    = "seaweedfs"

  size_master              = local.persistences.seaweedfs-master["size"]
  pvc_master               = "pvc-${local.persistences.seaweedfs-master["name"]}"
  pvc_master_access_modes  = "ReadWriteOnce"
  pvc_master_storage_class = local.storage_class_name

  size_volume              = local.persistences.seaweedfs-volume["size"]
  pvc_volume               = "pvc-${local.persistences.seaweedfs-volume["name"]}"
  pvc_volume_access_modes  = "ReadWriteOnce"
  pvc_volume_storage_class = local.storage_class_name

  database_host             = module.chart_postgresql.database_host
  database_port             = module.chart_postgresql.database_port
  database_seaweedfs_name   = module.chart_postgresql.database_seaweedfs_name
  database_seaweedfs_user   = module.chart_postgresql.database_seaweedfs_user
  database_seaweedfs_secret = module.chart_postgresql.database_seaweedfs_secret

  postgresql_image_repository = var.postgresql_image_repository
  postgresql_image_tag        = var.postgresql_image_tag

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_argo" {
  source = "./modules/chart_argo"

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.argo_chart_repository
  chart_name       = var.argo_chart_name
  chart_tag        = var.argo_chart_tag
  chart_release    = "argo-workflows"

  database_host   = module.chart_postgresql.database_host
  database_port   = module.chart_postgresql.database_port
  database_name   = module.chart_postgresql.database_argo_name
  database_user   = module.chart_postgresql.database_argo_user
  database_secret = module.chart_postgresql.database_argo_secret

  s3_host                = module.chart_seaweedfs.s3_host
  s3_port                = module.chart_seaweedfs.s3_port
  s3_bucket              = module.chart_seaweedfs.s3_argo_workflows_bucket
  s3_secret              = module.chart_seaweedfs.s3_secret
  s3_secret_key_username = module.chart_seaweedfs.s3_secret_key_argo_workflows_username
  s3_secret_key_password = module.chart_seaweedfs.s3_secret_key_argo_workflows_password

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_redis" {
  source = "./modules/chart_redis"

  tenant = module.kube_namespace.tenant

  image_registry             = local.image_registry
  image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.redis_chart_repository
  chart_name       = var.redis_chart_name
  chart_tag        = var.redis_chart_tag
  chart_release    = "redis"

  size_master              = local.persistences.redis-master["size"]
  pvc_master               = "pvc-${local.persistences.redis-master["name"]}"
  pvc_master_storage_class = local.storage_class_name

  size_replica              = local.persistences.redis-replica["size"]
  pvc_replica               = "pvc-${local.persistences.redis-replica["name"]}"
  pvc_replica_storage_class = local.storage_class_name

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_cosmotech_api" {
  source = "./modules/chart_cosmotech_api"

  tenant = module.kube_namespace.tenant

  # image_registry             = local.image_registry
  # image_registry_auth_secret = var.image_registry_auth_secret

  chart_repository = var.cosmotechapi_chart_repository
  chart_name       = var.cosmotechapi_chart_name
  chart_tag        = var.cosmotechapi_chart_tag
  chart_release    = "cosmotech-api"

  postgresql_host            = module.chart_postgresql.database_host
  postgresql_port            = module.chart_postgresql.database_port
  postgresql_database        = module.chart_postgresql.database_cosmotech_name
  postgresql_admin_username  = module.chart_postgresql.database_cosmotech_username_admin
  postgresql_admin_password  = module.chart_postgresql.database_cosmotech_password_admin
  postgresql_writer_username = module.chart_postgresql.database_cosmotech_username_writer
  postgresql_writer_password = module.chart_postgresql.database_cosmotech_password_writer
  postgresql_reader_username = module.chart_postgresql.database_cosmotech_username_reader
  postgresql_reader_password = module.chart_postgresql.database_cosmotech_password_reader

  s3_host                = module.chart_seaweedfs.s3_host
  s3_port                = module.chart_seaweedfs.s3_port
  s3_bucket              = module.chart_seaweedfs.s3_cosmotech_api_bucket
  s3_secret              = module.chart_seaweedfs.s3_secret
  s3_secret_key_username = module.chart_seaweedfs.s3_secret_key_cosmotech_api_username
  s3_secret_key_password = module.chart_seaweedfs.s3_secret_key_cosmotech_api_password

  cluster_domain = local.cluster_domain

  keycloak_client_id     = module.config_keycloak_realm.keycloak_api_client_id
  keycloak_client_secret = module.config_keycloak_realm.keycloak_api_client_secret

  # Ingress
  cosmotech_api_connect_timeout = "30s"
  cosmotech_api_query_timeout   = "60s"
  cosmotech_api_buffer_size     = "16K"
  cosmotech_api_max_file_size   = "300m"

  depends_on = [
    time_sleep.timer,
    module.chart_postgresql,
    module.chart_redis,
    module.chart_argo,
    module.config_harbor_project,
    module.config_keycloak_realm,
  ]
}


module "config_grafana_dashboard" {
  source = "./modules/config_grafana_dashboard"

  tenant               = module.kube_namespace.tenant
  cluster_domain       = local.cluster_domain
  namespace_monitoring = "monitoring"
  secret_redis         = module.chart_redis.redis_secret
  secret_postgresql    = module.chart_postgresql.postgresql_secret
}


module "config_harbor_project" {
  source = "./modules/config_harbor_project"

  tenant         = module.kube_namespace.tenant
  cluster_domain = local.cluster_domain
}


module "config_superset_oauth_provider" {
  source = "./modules/config_superset_oauth_provider"

  tenant         = module.kube_namespace.tenant
  cluster_domain = local.cluster_domain
  depends_on = [
    module.config_keycloak_realm
  ]
}
