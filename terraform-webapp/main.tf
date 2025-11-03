## Keycloak client
module "chart-keycloak-client" {
  source = "./modules/config-keycloak-client"

  cluster_domain = var.cluster_domain
  tenant = local.tenant
  webapp_name = local.webapp_name
}


## Cosmo Tech Webapp
module "chart-cosmotech-webapp" {
  source = "./modules/chart-cosmotech-webapp"

  webapp_name     = local.webapp_name
  tenant          = local.tenant
  cluster_domain  = var.cluster_domain
  organization_id = var.organization_id
}


# ## Superset
# module "chart-superset" {
#   source = "./modules/chart-superset"

#   release = "${local.webapp_name}-superset"
#   tenant  = var.tenant
# }


