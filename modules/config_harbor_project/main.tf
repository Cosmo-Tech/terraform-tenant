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


# -- Project ---
resource "harbor_project" "tenant" {
  name = var.tenant
}
# -- Project ---


# --- User ---
resource "random_password" "password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}

resource "kubernetes_secret" "harbor_tenant" {
  metadata {
    name      = "harbor-user"
    namespace = var.tenant
  }

  data = {
    "project" : var.tenant,
    "username" : var.tenant,
    "password" : random_password.password.result,
    "email" : "${var.tenant}@${var.tenant}.local", # email is mandatory, this is just a fake one but it can be anything
  }

  type = "Opaque"
}

resource "harbor_user" "tenant" {
  username = kubernetes_secret.harbor_tenant.data["username"]
  password = kubernetes_secret.harbor_tenant.data["password"]
  full_name = kubernetes_secret.harbor_tenant.data["username"]
  email = kubernetes_secret.harbor_tenant.data["email"]
}

resource "harbor_project_member_user" "tenant" {
  project_id    = harbor_project.tenant.id
  user_name     = harbor_user.tenant.username
  role          = "developer"
}
# --- User ---
