## Namespace
module "kube-namespace" {
  source = "./modules/kube-namespace"

  tenant_name = var.tenant_name
}

## Persistant storage
module "kube-storage-azure" {
  source = "./modules/kube-storage/azure"

  tenant_name = var.tenant_name

  zz_azure_subscription_id = var.zz_azure_subscription_id
  zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
  zz_azure_aks_rg_name = var.zz_azure_aks_rg_name
  zz_azure_aks_rg_region = var.zz_azure_aks_rg_region
}

# ## Persistant storage
# module "kube-storage-aws" {
#   source = "./modules/kube-storage/aws"

#   tenant_name = var.tenant_name
# }

# ## Persistant storage
# module "kube-storage-gcp" {
#   source = "./modules/kube-storage/gcp"

#   tenant_name = var.tenant_name
# }


# ## Config: Keycloak realm
# module "config-keycloak-realm" {
#   source = "./modules/config-keycloak-realm"

# }


# ## Config: Grafana dashboard
# module "config-grafana-dashboard" {
#   source = "./modules/config-grafana-dashboard"

# }


# ## Helm Chart: Cosmo Tech API
# module "chart-cosmotech-api" {
#   source = "./modules/chart-cosmotech-api"

#   tenant_name = module.namespace.tenant_namespace
# }


# ## Helm Chart: Redis
# module "chart-redis" {
#   source = "./modules/chart-redis"

#   tenant_name = module.namespace.tenant_namespace
# }


# ## Helm Chart: Argo Workflows
# module "chart-argo" {
#   source = "./modules/chart-argo"

#   tenant_name = module.namespace.tenant_namespace
# }


## Helm Chart: PostgreSQL
module "chart-postgresql" {
  source = "./modules/chart-postgresql"

  tenant_namespace = module.namespace.tenant_namespace

  # zz_azure_subscription_id = var.zz_azure_subscription_id
  # zz_azure_entra_tenant_id = var.zz_azure_entra_tenant_id
  # zz_azure_aks_rg_name = var.zz_azure_aks_rg_name
  # zz_azure_aks_rg_region = var.zz_azure_aks_rg_region
}


# ## Helm Chart: SeaweedFS
# module "seaweedfs" {
#   source = "./modules/seaweedfs"

#   tenant_name = module.namespace.tenant_namespace
# }


# ## Helm Chart: RabbitMQ
# module "rabbitmq" {
#   source = "./modules/rabbitmq"

#   tenant_name = module.namespace.tenant_namespace
# }


# ## Helm Chart: Harbor
# module "harbor" {
#   source = "./modules/harbor"

#   tenant_name = module.namespace.tenant_namespace
# }


