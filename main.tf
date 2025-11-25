locals {
  storage_class_name = "cosmotech-retain"
  persistences = {
    postgresql = {
      size = 8
      pvc  = "pvc-${module.kube-namespace.tenant}-postgresql"
    }
    seaweedfs-master = {
      size = 32
      pvc  = "pvc-${module.kube-namespace.tenant}-seaweedfs-master"
    }
    seaweedfs-volume = {
      size = 32
      pvc  = "pvc-${module.kube-namespace.tenant}-seaweedfs-volume"
    }
    redis-master = {
      size = 32
      pvc  = "pvc-${module.kube-namespace.tenant}-redis-master"
    }
    redis-replica = {
      size = 32
      pvc  = "pvc-${module.kube-namespace.tenant}-redis-replica"
    }


    # # TEMPORARY TO REMOVE
    # postgresql-keycloak = {
    #   size = 32
    #   pvc  = "pvc-${module.kube-namespace.tenant}-keycloak-postgresql"
    # }
  }
}

## namespace
module "kube-namespace" {
  source = "./modules/kube-namespace"

  tenant = var.tenant
}


## (config) Keycloak realm
module "config-keycloak-realm" {
  source = "./modules/config-keycloak-realm"

  tenant         = module.kube-namespace.tenant
  cluster_domain = var.cluster_domain
}


# module "storage-azure" {
#   source = "./modules/kube-storage/azure"

#   # Fill the foreach loop with values only if right cloud provider is given
#   for_each = var.cloud_provider == "azure" ? local.persistences : {}

#   tenant             = module.kube-namespace.tenant
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

#   tenant             = module.kube-namespace.tenant
#   resource           = each.key
#   size               = each.value.size
#   storage_class_name = local.storage_class_name
#   region = var.region
#   cloud_provider = var.cloud_provider
# }






module "storage" {
  # The 'source' cannot use a variable, it's why it's dynamically replaced from ./_run-terraform.sh according to the variable cloud_provider
  source = "./modules/kube-storage/azure"

  for_each = local.persistences

  tenant             = module.kube-namespace.tenant
  resource           = each.key
  size               = each.value.size
  storage_class_name = local.storage_class_name
  region             = var.region
  cluster_name       = var.kubernetes_context
  cloud_provider     = var.cloud_provider
}



# Timer to wait for storage to be created before continue
resource "null_resource" "timer" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
}



## (Helm Chart) PostgreSQL
module "chart-postgresql" {
  source = "./modules/chart-postgresql"

  release = "postgresql"
  tenant  = module.kube-namespace.tenant

  size              = local.persistences.postgresql["size"]
  pvc               = local.persistences.postgresql["pvc"]
  pvc_storage_class = local.storage_class_name

  # size              = module.kube-storage-azure-postgresql[0].size
  # pvc               = module.kube-storage-azure-postgresql[0].pvc
  # pvc_storage_class = module.kube-storage-azure-postgresql[0].storage_class

  depends_on = [
    null_resource.timer,
  ]
}


## (Helm Chart) SeaweedFS
module "chart-seaweedfs" {
  source = "./modules/chart-seaweedfs"

  release = "seaweedfs"
  tenant  = module.kube-namespace.tenant

  size_master              = local.persistences.seaweedfs-master["size"]
  pvc_master               = local.persistences.seaweedfs-master["pvc"]
  pvc_master_access_modes  = "ReadWriteOnce"
  pvc_master_storage_class = local.storage_class_name

  size_volume              = local.persistences.seaweedfs-volume["size"]
  pvc_volume               = local.persistences.seaweedfs-volume["pvc"]
  pvc_volume_access_modes  = "ReadWriteOnce"
  pvc_volume_storage_class = local.storage_class_name

  # size_master              = module.kube-storage-azure-seaweedfs-master[0].size
  # pvc_master               = module.kube-storage-azure-seaweedfs-master[0].pvc
  # pvc_master_access_modes  = module.kube-storage-azure-seaweedfs-master[0].pvc_access_modes
  # pvc_master_storage_class = module.kube-storage-azure-seaweedfs-master[0].storage_class

  # size_volume              = module.kube-storage-azure-seaweedfs-volume[0].size
  # pvc_volume               = module.kube-storage-azure-seaweedfs-volume[0].pvc
  # pvc_volume_access_modes  = module.kube-storage-azure-seaweedfs-volume[0].pvc_access_modes
  # pvc_volume_storage_class = module.kube-storage-azure-seaweedfs-volume[0].storage_class

  database_host             = module.chart-postgresql.database_host
  database_port             = module.chart-postgresql.database_port
  database_seaweedfs_name   = module.chart-postgresql.database_seaweedfs_name
  database_seaweedfs_user   = module.chart-postgresql.database_seaweedfs_user
  database_seaweedfs_secret = module.chart-postgresql.database_seaweedfs_secret

  depends_on = [
    null_resource.timer,
  ]
}


## (Helm Chart) Argo Workflows
module "chart-argo" {
  source = "./modules/chart-argo"

  release = "argo-workflows"
  tenant  = module.kube-namespace.tenant

  database_host   = module.chart-postgresql.database_host
  database_port   = module.chart-postgresql.database_port
  database_name   = module.chart-postgresql.database_argo_name
  database_user   = module.chart-postgresql.database_argo_user
  database_secret = module.chart-postgresql.database_argo_secret

  s3_host                = module.chart-seaweedfs.s3_host
  s3_port                = module.chart-seaweedfs.s3_port
  s3_bucket              = module.chart-seaweedfs.s3_argo_workflows_bucket
  s3_secret              = module.chart-seaweedfs.s3_secret
  s3_secret_key_username = module.chart-seaweedfs.s3_secret_key_argo_workflows_username
  s3_secret_key_password = module.chart-seaweedfs.s3_secret_key_argo_workflows_password

  depends_on = [
    null_resource.timer,
  ]
}


## (Helm Chart) Redis
module "chart-redis" {
  source = "./modules/chart-redis"

  release = "redis"
  tenant  = module.kube-namespace.tenant

  size_master              = local.persistences.redis-master["size"]
  pvc_master               = local.persistences.redis-master["pvc"]
  pvc_master_storage_class = local.storage_class_name

  size_replica              = local.persistences.redis-replica["size"]
  pvc_replica               = local.persistences.redis-replica["pvc"]
  pvc_replica_storage_class = local.storage_class_name

  # size_master              = module.kube-storage-azure-redis-master[0].size
  # pvc_master               = module.kube-storage-azure-redis-master[0].pvc
  # pvc_master_storage_class = module.kube-storage-azure-redis-master[0].storage_class

  # size_replica              = module.kube-storage-azure-redis-replica[0].size
  # pvc_replica               = module.kube-storage-azure-redis-replica[0].pvc
  # pvc_replica_storage_class = module.kube-storage-azure-redis-replica[0].storage_class

  depends_on = [
    null_resource.timer,
  ]
}


## (Helm Chart) Cosmo Tech API
module "chart-cosmotech-api" {
  source = "./modules/chart-cosmotech-api"

  release = "cosmotech-api"
  tenant  = module.kube-namespace.tenant

  postgresql_host            = module.chart-postgresql.database_host
  postgresql_port            = module.chart-postgresql.database_port
  postgresql_database        = module.chart-postgresql.database_cosmotech_name
  postgresql_admin_username  = module.chart-postgresql.database_cosmotech_username_admin
  postgresql_admin_password  = module.chart-postgresql.database_cosmotech_password_admin
  postgresql_writer_username = module.chart-postgresql.database_cosmotech_username_writer
  postgresql_writer_password = module.chart-postgresql.database_cosmotech_password_writer
  postgresql_reader_username = module.chart-postgresql.database_cosmotech_username_reader
  postgresql_reader_password = module.chart-postgresql.database_cosmotech_password_reader

  # redis_password = module.chart-redis.redis_password

  s3_host                = module.chart-seaweedfs.s3_host
  s3_port                = module.chart-seaweedfs.s3_port
  s3_bucket              = module.chart-seaweedfs.s3_cosmotech_api_bucket
  s3_secret              = module.chart-seaweedfs.s3_secret
  s3_secret_key_username = module.chart-seaweedfs.s3_secret_key_cosmotech_api_username
  s3_secret_key_password = module.chart-seaweedfs.s3_secret_key_cosmotech_api_password

  cluster_domain = var.cluster_domain

  keycloak_client_id     = module.config-keycloak-realm.keycloak_api_client_id
  keycloak_client_secret = module.config-keycloak-realm.keycloak_api_client_secret

  depends_on = [
    null_resource.timer,
    module.chart-postgresql,
    module.chart-redis,
    # module.config-keycloak-realm,
  ]
}



# (config) Grafana dashboard
module "config-grafana-dashboard" {
  source = "./modules/config-grafana-dashboard"

  tenant               = module.kube-namespace.tenant
  cluster_domain       = var.cluster_domain
  namespace_monitoring = "cosmotech-monitoring"
}