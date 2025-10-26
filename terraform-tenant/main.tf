## namespace
module "kube-namespace" {
  source = "./modules/kube-namespace"

  tenant = var.tenant
}


# ## (config) Keycloak realm
# module "config-keycloak-realm" {
#   source = "./modules/config-keycloak-realm"
# }


# ## (config) Grafana dashboard
# module "config-grafana-dashboard" {
#   source = "./modules/config-grafana-dashboard"
# }


## (persistent storage) PostgreSQL
module "kube-storage-azure-postgresql" {
  source = "./modules/kube-storage/azure"

  count = var.cloud_provider == "azure" ? 1 : 0

  tenant   = module.kube-namespace.tenant
  resource = "postgresql"
  size     = 8

  zz_azure_subscription_id = var.zz_azure_subscription_id
  zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
  zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
  zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
}


# ## (persistent storage) SeaweedFS
# module "kube-storage-azure-seaweedfs-master" {
#   source = "./modules/kube-storage/azure"

#   count = var.cloud_provider == "azure" ? 1 : 0

#   tenant   = module.kube-namespace.tenant
#   resource = "seaweedfs-master"
#   size     = 8

#   zz_azure_subscription_id = var.zz_azure_subscription_id
#   zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
#   zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
#   zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
# }


# ## (persistent storage) SeaweedFS
# module "kube-storage-azure-seaweedfs-volume" {
#   source = "./modules/kube-storage/azure"

#   count = var.cloud_provider == "azure" ? 1 : 0

#   tenant   = module.kube-namespace.tenant
#   resource = "seaweedfs-volume"
#   size     = 8

#   zz_azure_subscription_id = var.zz_azure_subscription_id
#   zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
#   zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
#   zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
# }


# ## (persistent storage) Harbor
# module "kube-storage-azure-harbor" {
#   source = "./modules/kube-storage/azure"

#   count = var.cloud_provider == "azure" ? 1 : 0

#   tenant   = module.kube-namespace.tenant
#   resource = "harbor"
#   size     = 8

#   zz_azure_subscription_id = var.zz_azure_subscription_id
#   zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
#   zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
#   zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
# }


# ## (persistent storage) Redis
# module "kube-storage-azure-redis" {
#   source = "./modules/kube-storage/azure"

#   count = var.cloud_provider == "azure" ? 1 : 0

#   tenant   = module.kube-namespace.tenant
#   resource = "redis"
#   size     = 8

#   zz_azure_subscription_id = var.zz_azure_subscription_id
#   zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
#   zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
#   zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
# }


# ## (Helm Chart) Cosmo Tech API
# module "chart-cosmotech-api" {
#   source = "./modules/chart-cosmotech-api"

#   tenant = module.kube-namespace.tenant
# }


# ## (Helm Chart) Redis
# module "chart-redis" {
#   source = "./modules/chart-redis"

#   tenant = module.kube-namespace.tenant
#   pvc    = module.kube-storage-azure-redis[0].pvc
# }


# ## (Helm Chart) Argo Workflows
# module "chart-argo" {
#   source = "./modules/chart-argo"

#   tenant = module.kube-namespace.tenant
# }


## (Helm Chart) PostgreSQL
module "chart-postgresql" {
  source = "./modules/chart-postgresql"

  release           = "postgresql"
  tenant            = module.kube-namespace.tenant
  size              = module.kube-storage-azure-postgresql[0].size
  pvc               = module.kube-storage-azure-postgresql[0].pvc
  pvc_storage_class = module.kube-storage-azure-postgresql[0].pvc_storage_class
}


# ## (Helm Chart) SeaweedFS
# module "chart-seaweedfs" {
#   source = "./modules/chart-seaweedfs"

#   release = "seaweedfs"
#   tenant  = module.kube-namespace.tenant

#   size_master              = module.kube-storage-azure-seaweedfs-master[0].size
#   pvc_master               = module.kube-storage-azure-seaweedfs-master[0].pvc
#   pvc_master_access_modes  = module.kube-storage-azure-seaweedfs-master[0].pvc_access_modes
#   pvc_master_storage_class = module.kube-storage-azure-seaweedfs-master[0].pvc_storage_class

#   size_volume              = module.kube-storage-azure-seaweedfs-volume[0].size
#   pvc_volume               = module.kube-storage-azure-seaweedfs-volume[0].pvc
#   pvc_volume_access_modes  = module.kube-storage-azure-seaweedfs-volume[0].pvc_access_modes
#   pvc_volume_storage_class = module.kube-storage-azure-seaweedfs-volume[0].pvc_storage_class

#   database_host             = module.chart-postgresql.database_host
#   database_seaweedfs_name   = module.chart-postgresql.database_seaweedfs_name
#   database_seaweedfs_secret = module.chart-postgresql.database_seaweedfs_secret
# }


# ## (Helm Chart) RabbitMQ
# module "rabbitmq" {
#   source = "./modules/rabbitmq"

#   tenant = module.kube-namespace.tenant
# }


# ## (Helm Chart) Harbor
# module "harbor" {
#   source = "./modules/harbor"

#   tenant = module.kube-namespace.tenant
#   pvc    = module.kube-storage-azure-harbor[0].pvc
# }

