locals {
  storage_class_name = "cosmotech-retain"
  persistences = {
    postgresql = {
      size = 8
      pvc  = "pvc-${module.kube_namespace.tenant}-postgresql"
    }
    seaweedfs-master = {
      size = 32
      pvc  = "pvc-${module.kube_namespace.tenant}-seaweedfs-master"
    }
    seaweedfs-volume = {
      size = 32
      pvc  = "pvc-${module.kube_namespace.tenant}-seaweedfs-volume"
    }
    redis-master = {
      size = 32
      pvc  = "pvc-${module.kube_namespace.tenant}-redis-master"
    }
    redis-replica = {
      size = 32
      pvc  = "pvc-${module.kube_namespace.tenant}-redis-replica"
    }
  }
}

module "kube_namespace" {
  source = "./modules/kube_namespace"

  tenant = var.tenant
}


module "config_keycloak_realm" {
  source = "./modules/config_keycloak_realm"

  tenant         = module.kube_namespace.tenant
  cluster_domain = var.cluster_domain
}


# module "storage-azure" {
#   source = "./modules/kube-storage/azure"

#   # Fill the foreach loop with values only if right cloud provider is given
#   for_each = var.cloud_provider == "azure" ? local.persistences : {}

#   tenant             = module.kube_namespace.tenant
#   resource           = each.key
#   size               = each.value.size
#   storage_class_name = local.storage_class_name
#   region = var.region
#   cluster_name = var.kubernetes_context
#   cloud_provider = var.cloud_provider
# }


# module "storage-aws" {
#   source = "./modules/kube-storage/azure"

#   # Fill the foreach loop with values only if right cloud provider is given
#   for_each = var.cloud_provider == "aws" ? local.persistences : {}

#   tenant             = module.kube_namespace.tenant
#   resource           = each.key
#   size               = each.value.size
#   storage_class_name = local.storage_class_name
#   region = var.region
#   cloud_provider = var.cloud_provider
# }


module "storage" {
  # The 'source' cannot use a variable, it's why it's dynamically replaced from ./_run-terraform.sh according to the variable cloud_provider
  source = "./modules/storage/azure"

  for_each = local.persistences

  tenant             = module.kube_namespace.tenant
  resource           = each.key
  size               = each.value.size
  storage_class_name = local.storage_class_name
  region             = var.cluster_region
  cluster_name       = var.cluster_name
  cloud_provider     = var.cloud_provider
}


# Timer to wait for storage to be created before continue
resource "time_sleep" "timer" {
  create_duration = "30s"
}
# resource "null_resource" "timer" {
#   provisioner "local-exec" {
#     command = "sleep 30"
#   }
# }


module "chart_postgresql" {
  source = "./modules/chart_postgresql"

  release = "postgresql"
  tenant  = module.kube_namespace.tenant

  size              = local.persistences.postgresql["size"]
  pvc               = local.persistences.postgresql["pvc"]
  pvc_storage_class = local.storage_class_name

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_seaweedfs" {
  source = "./modules/chart_seaweedfs"

  release = "seaweedfs"
  tenant  = module.kube_namespace.tenant

  size_master              = local.persistences.seaweedfs-master["size"]
  pvc_master               = local.persistences.seaweedfs-master["pvc"]
  pvc_master_access_modes  = "ReadWriteOnce"
  pvc_master_storage_class = local.storage_class_name

  size_volume              = local.persistences.seaweedfs-volume["size"]
  pvc_volume               = local.persistences.seaweedfs-volume["pvc"]
  pvc_volume_access_modes  = "ReadWriteOnce"
  pvc_volume_storage_class = local.storage_class_name

  database_host             = module.chart_postgresql.database_host
  database_port             = module.chart_postgresql.database_port
  database_seaweedfs_name   = module.chart_postgresql.database_seaweedfs_name
  database_seaweedfs_user   = module.chart_postgresql.database_seaweedfs_user
  database_seaweedfs_secret = module.chart_postgresql.database_seaweedfs_secret

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_argo" {
  source = "./modules/chart_argo"

  release = "argo-workflows"
  tenant  = module.kube_namespace.tenant

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

  release = "redis"
  tenant  = module.kube_namespace.tenant

  size_master              = local.persistences.redis-master["size"]
  pvc_master               = local.persistences.redis-master["pvc"]
  pvc_master_storage_class = local.storage_class_name

  size_replica              = local.persistences.redis-replica["size"]
  pvc_replica               = local.persistences.redis-replica["pvc"]
  pvc_replica_storage_class = local.storage_class_name

  depends_on = [
    time_sleep.timer,
  ]
}


module "chart_cosmotech_api" {
  source = "./modules/chart_cosmotech_api"

  release = "cosmotech-api"
  tenant  = module.kube_namespace.tenant

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

  cluster_domain = var.cluster_domain

  keycloak_client_id     = module.config_keycloak_realm.keycloak_api_client_id
  keycloak_client_secret = module.config_keycloak_realm.keycloak_api_client_secret

  depends_on = [
    time_sleep.timer,
    module.chart_postgresql,
    module.chart_redis,
  ]
}


module "config_grafana_dashboard" {
  source = "./modules/config_grafana_dashboard"

  tenant               = module.kube_namespace.tenant
  cluster_domain       = var.cluster_domain
  namespace_monitoring = "monitoring"
  secret_redis         = module.chart_redis.redis_secret
  secret_postgresql    = module.chart_postgresql.postgresql_secret
}


module "config_harbor_project" {
  source = "./modules/config_harbor_project"

  tenant               = module.kube_namespace.tenant
  cluster_domain       = var.cluster_domain
}
