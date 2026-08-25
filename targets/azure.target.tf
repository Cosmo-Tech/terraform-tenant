terraform {
  backend "azurerm" {
    key                  = "$TEMPLATE_state_file_name"
    resource_group_name  = "$TEMPLATE_state_storage_name"
    storage_account_name = "$TEMPLATE_state_storage_name"
    container_name       = "$TEMPLATE_state_storage_name"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_entra_tenant_id
}

variable "azure_subscription_id" { type = string }
variable "azure_entra_tenant_id" { type = string }

data "azurerm_kubernetes_cluster" "cluster" {
  name                = "$TEMPLATE_cluster_name"
  resource_group_name = "$TEMPLATE_cluster_name"
}


module "storage" {
  source = "git::https://github.com/cosmo-tech/terraform-azure.git//terraform-cluster/modules/storage"

  for_each = var.cloud_provider == "azure" ? local.tenant_recipe_persistences : {}

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