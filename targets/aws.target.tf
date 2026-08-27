terraform {
  backend "s3" {
    key    = "$TEMPLATE_state_file_name"
    bucket = "cosmotech-states"
    region = "$TEMPLATE_cluster_region"
  }
}

provider "aws" {
  region = var.region
}

module "storage" {
  source = "git::https://github.com/cosmo-tech/terraform-aws.git//terraform-cluster/modules/storage"

  for_each = var.cloud_provider == "aws" ? local.tenant_recipe_persistences : {}

  namespace          = module.kube_namespace.tenant_namespace
  main_name          = each.value.main_name
  pvc_name           = each.value.pvc_name
  size               = each.value.size
  resource_group     = data.azurerm_kubernetes_cluster.cluster.node_resource_group
  storage_class_name = local.storage_class_name
  region             = var.cluster_region
  cloud_provider     = var.cloud_provider
  create_pvc         = each.value.create_pvc

  depends_on = [
    module.kube_namespace,
  ]
}