terraform {
  backend "gcs" {
    bucket = "cosmotech-states"
    prefix = "$TEMPLATE_state_file_name"
  }
}

provider "google" {
  project = var.project_id
  region  = var.cluster_region
}

variable "project_id" { type = string }

data "terraform_remote_state" "terraform_cluster" {
  backend = "gcs"
  config = {
    bucket = "cosmotech-states"
    # prefix = ""
  }
}

data "google_client_config" "current" {}

module "storage" {
  source = "git::https://github.com/cosmo-tech/terraform-gcp.git//terraform-cluster/modules/storage?ref=${local.module_storage_gcp_tag}"

  for_each = var.cloud_provider == "gcp" ? local.tenant_recipe_persistences : {}

  namespace          = local.tenant_namespace
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