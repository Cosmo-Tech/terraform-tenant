## Namespace
module "kube-namespace" {
  source = "./modules/kube-namespace"

  tenant = var.tenant
}

## Persistant storage Redis
module "kube-storage-azure-redis" {
  source = "./modules/kube-storage/azure"

  count = var.cloud_provider == "azure" ? 1 : 0

  tenant   = module.kube-namespace.tenant
  resource = "redis"
  size     = 8

  zz_azure_subscription_id = var.zz_azure_subscription_id
  zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
  zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
  zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
}

## Persistant storage PostgreSQL
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

## Persistant storage SeaweedFS
module "kube-storage-azure-seaweedfs" {
  source = "./modules/kube-storage/azure"

  count = var.cloud_provider == "azure" ? 1 : 0

  tenant   = module.kube-namespace.tenant
  resource = "seaweedfs"
  size     = 8

  zz_azure_subscription_id = var.zz_azure_subscription_id
  zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
  zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
  zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
}

## Persistant storage Harbor
module "kube-storage-azure-harbor" {
  source = "./modules/kube-storage/azure"

  count = var.cloud_provider == "azure" ? 1 : 0

  tenant   = module.kube-namespace.tenant
  resource = "harbor"
  size     = 8

  zz_azure_subscription_id = var.zz_azure_subscription_id
  zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
  zz_azure_aks_rg_name     = var.zz_azure_aks_rg_name
  zz_azure_aks_rg_region   = var.zz_azure_aks_rg_region
}

# ## Config: Keycloak realm
# module "config-keycloak-realm" {
#   source = "./modules/config-keycloak-realm"

# }

# ## Config: Grafana dashboard
# module "config-grafana-dashboard" {
#   source = "./modules/config-grafana-dashboard"

# }

# ## Helm Chart Cosmo Tech API
# module "chart-cosmotech-api" {
#   source = "./modules/chart-cosmotech-api"

#   tenant = module.kube-namespace.tenant
# }

# ## Helm Chart Redis
# module "chart-redis" {
#   source = "./modules/chart-redis"

#   tenant = module.kube-namespace.tenant
  # pvc    = module.kube-storage-azure-redis.pvc
# }

# ## Helm Chart Argo Workflows
# module "chart-argo" {
#   source = "./modules/chart-argo"

#   tenant = module.kube-namespace.tenant
# }

## Helm Chart PostgreSQL
module "chart-postgresql" {
  source = "./modules/chart-postgresql"

  tenant = module.kube-namespace.tenant
  pvc    = module.kube-storage-azure-postgresql[0].pvc
}

# ## Helm Chart SeaweedFS
# module "seaweedfs" {
#   source = "./modules/seaweedfs"

#   tenant = module.kube-namespace.tenant
  # pvc    = module.kube-storage-azure-seaweedfs.pvc
# }

# ## Helm Chart RabbitMQ
# module "rabbitmq" {
#   source = "./modules/rabbitmq"

#   tenant = module.kube-namespace.tenant
# }

# ## Helm Chart Harbor
# module "harbor" {
#   source = "./modules/harbor"

#   tenant = module.kube-namespace.tenant
  # pvc    = module.kube-storage-azure-harbor.pvc
# }

