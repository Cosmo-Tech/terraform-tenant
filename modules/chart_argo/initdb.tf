terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}


locals {
  initdb_template = templatefile("${path.module}/templates/initdb.yaml", local.initdb_values)
  initdb_values = {
    NAMESPACE                   = var.tenant
    IMAGE_REGISTRY              = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET  = var.image_registry_auth_secret
    POSTGRESQL_IMAGE_REPOSITORY = var.postgresql_image_repository
    POSTGRESQL_IMAGE_TAG        = var.postgresql_image_tag
    DB_HOST                     = var.database_host
    DB_PORT                     = var.database_port
    DB_POSTGRES_PASSWORD        = data.kubernetes_secret.postgresql-config.data["password"]
    ARGO_DATABASE               = kubernetes_secret.postgresql-argo.data["database-name"]
    ARGO_USERNAME               = kubernetes_secret.postgresql-argo.data["database-username"]
    ARGO_PASSWORD               = kubernetes_secret.postgresql-argo.data["database-password"]
  }
}


resource "kubectl_manifest" "initdb" {
  yaml_body = local.initdb_template

  lifecycle {
    replace_triggered_by = [
      terraform_data.initdb_trigger
    ]
  }
}

resource "terraform_data" "initdb_trigger" {
  input = {
    values = local.initdb_template
  }
}


data "kubernetes_secret" "postgresql-config" {
  metadata {
    namespace = var.tenant
    name      = "postgresql-config"
  }
}


# Specific secret containing Argo Workflows database informations
resource "kubernetes_secret" "postgresql-argo" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-argo"
  }

  data = {
    "database-name"     = "argo"
    "database-username" = "argo"
    "database-password" = random_password.argo_database_password.result
  }
}


resource "random_password" "argo_database_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}
