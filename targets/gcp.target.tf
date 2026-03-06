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
  source = "git::https://github.com/cosmo-tech/terraform-gcp.git//terraform-cluster/modules/storage"

  for_each = var.cloud_provider == "gcp" ? local.persistences : {}

  namespace          = module.kube_namespace.tenant
  resource           = each.value.name
  size               = each.value.size
  storage_class_name = local.storage_class_name
  region             = var.cluster_region
  cloud_provider     = var.cloud_provider
}
