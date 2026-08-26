locals {
  template_file = templatefile("${path.module}/cnpg-cluster.yaml", local.template_values)
  template_values = {
    PERSISTENCE_SIZE            = var.size
    PERSISTENCE_PVC             = var.pvc
    PERSISTENCE_STORAGE_CLASS   = var.pvc_storage_class
    POSTGRESQL_SECRET_CONFIG    = kubernetes_secret.postgresql-config.metadata[0].name
    POSTGRESQL_IMAGE_REPOSITORY = var.postgresql_image_repository
    POSTGRESQL_IMAGE_TAG        = var.postgresql_image_tag
    IMAGE_REGISTRY              = var.image_registry
    IMAGE_REGISTRY_AUTH_SECRET  = var.image_registry_auth_secret
    NAMESPACE                   = var.tenant
  }

  database_host = "${kubectl_manifest.postgresql.name}-rw.${var.tenant}.svc.cluster.local"
  database_port = "5432"
}


# Just generate an amount of secured passwords
resource "random_password" "password" {
  count = 10

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
    namespace = var.tenant
    name      = "postgresql-config"
  }

  data = {
    "username" = "postgres"
    "password" = random_password.password[1].result
  }

  depends_on = [
    random_password.password,
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
    var.tenant,
    var.pvc,
    # kubernetes_secret.postgresql-config,
    # kubernetes_secret.postgresql-seaweedfs,
    # kubernetes_secret.postgresql-argo,
  ]
}
