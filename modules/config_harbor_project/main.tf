terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "~> 3.11.3"
    }
  }
}

provider "harbor" {
  url = "http://${var.cluster_domain}"
  # url      = "http://${var.cluster_domain}/harbor"

  username = "admin"
  password = data.kubernetes_secret.harbor.data["harbor_admin_password"]
}

data "kubernetes_secret" "harbor" {
  metadata {
    namespace = "harbor"
    name      = "harbor-config"
  }
}

resource "harbor_project" "tenant" {
  name = var.tenant
}
