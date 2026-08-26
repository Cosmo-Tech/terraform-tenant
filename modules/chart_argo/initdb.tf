terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}


locals {
  initdb_template = templatefile("${path.module}/initdb/argo.yaml", local.initdb_values)
  initdb_values = {
    NAMESPACE                   = var.tenant
    IMAGE_REGISTRY              = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET  = var.image_registry_auth_secret
    POSTGRESQL_IMAGE_REPOSITORY = var.postgresql_image_repository
    POSTGRESQL_IMAGE_TAG        = var.postgresql_image_tag
    DB_HOST                     = var.database_host
    DB_PORT                     = var.database_port
    DB_POSTGRES_PASSWORD        = kubernetes_secret.postgresql-config.data["password"]
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

  depends_on = [
    kubectl_manifest.postgresql
  ]
}

resource "terraform_data" "initdb_trigger" {
  input = {
    values = local.initdb_template
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
    "database-password" = random_password.password[3].result
  }
}