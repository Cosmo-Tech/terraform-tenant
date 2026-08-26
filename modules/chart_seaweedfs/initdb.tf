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
    SEAWEEDFS_DATABASE          = kubernetes_secret.postgresql-seaweedfs.data["postgresql-database"]
    SEAWEEDFS_USERNAME          = kubernetes_secret.postgresql-seaweedfs.data["postgresql-username"]
    SEAWEEDFS_PASSWORD          = kubernetes_secret.postgresql-seaweedfs.data["postgresql-password"]
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


# Specific secret containing SeadweedFS database informations
# SeaweedFS chart requires to have a "postgresql-password" key in its secret
resource "kubernetes_secret" "postgresql-seaweedfs" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-seaweedfs"
  }

  data = {
    "postgresql-database" = "seaweedfs"
    "postgresql-username" = "seaweedfs"
    "postgresql-password" = random_password.seaweedfs_postgresql_password.result
  }
}



resource "random_password" "seaweedfs_postgresql_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}