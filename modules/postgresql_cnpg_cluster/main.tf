terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}


locals {
  template_file = templatefile("${path.module}/templates/cnpg-cluster.yaml", local.template_values)
  template_values = {
    NAMESPACE                 = var.namespace
    REGISTRY                  = var.registry
    REGISTRY_AUTH_SECRET      = var.registry_auth_secret
    POSTGRESQL_IMAGE_NAME     = var.postgresql_image_name
    POSTGRESQL_IMAGE_TAG      = var.postgresql_image_tag
    PERSISTENCE_SIZE          = var.size
    PERSISTENCE_PVC           = var.pvc
    PERSISTENCE_STORAGE_CLASS = var.pvc_storage_class
    POSTGRESQL_SECRET_CONFIG  = kubernetes_secret.postgresql-config.metadata[0].name
  }

  database_host = "${var.namespace}-postgresql-rw.${var.namespace}.svc.cluster.local"
  database_port = "5432"
}


resource "random_password" "postgres_password" {
  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


# Main secret containing PostgreSQL informations
# The key "password" is a common value that most of charts uses by default
resource "kubernetes_secret" "postgresql-config" {
  type = "Opaque"

  metadata {
    namespace = var.namespace
    name      = "postgresql-config"
  }

  data = {
    "username" = "postgres"
    "password" = random_password.postgres_password.result
  }

  depends_on = [
    random_password.postgres_password,
  ]
}


resource "kubectl_manifest" "postgresql" {
  yaml_body = local.template_file

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  timeouts {
    create = "300s"
  }

  depends_on = [
    var.namespace,
    var.pvc,
  ]
}
