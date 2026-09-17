terraform {
  backend "http" {
    update_method          = "PUT"
    lock_method            = "POST"
    unlock_method          = "DELETE"
    skip_cert_verification = true

    address        = "$TEMPLATE_state_url"
    lock_address   = "$TEMPLATE_state_url/lock"
    unlock_address = "$TEMPLATE_state_url/lock"
  }
}

variable "state_host" { type = string }

locals {
  cloud_identity = {}
  lb_annotations = {}
  lb_ip          = ""
}

module "storage" {
  source = "git::https://github.com/cosmo-tech/terraform-onprem.git//terraform-cluster/modules/storage?ref=${local.module_storage_kob_tag}"

  for_each = var.cloud_provider == "kob" ? local.tenant_recipe_persistences : {}

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