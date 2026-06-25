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

  for_each = var.cloud_provider == "aws" ? local.persistences : {}

  namespace          = module.kube_namespace.tenant
  resource           = each.value.name
  size               = each.value.size
  storage_class_name = local.storage_class_name
  region             = var.cluster_region
  cloud_provider     = var.cloud_provider
  pvc_annotations    = each.value.pvc_annotations
}