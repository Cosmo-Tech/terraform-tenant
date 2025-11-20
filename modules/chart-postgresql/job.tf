terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
  }
}

resource "kubectl_manifest" "seaweedfs_initdb" {
  yaml_body = templatefile("${path.module}/postgress-seaweedfs-init.yaml",
    {
      namespace         = var.tenant
      postgres_password = kubernetes_secret.postgresql-config.data["postgres-password"]
      db_host           = local.database_host
      db_port           = local.database_port

      seaweedfs_database = kubernetes_secret.postgresql-seaweedfs.data["postgresql-database"]
      seaweedfs_username = kubernetes_secret.postgresql-seaweedfs.data["postgresql-username"]
      seaweedfs_password = kubernetes_secret.postgresql-seaweedfs.data["postgresql-password"]
    }
  )
}

resource "kubectl_manifest" "argo_initdb" {
  yaml_body = templatefile("${path.module}/postgress-argo-init.yaml",
    {
      namespace         = var.tenant
      postgres_password = kubernetes_secret.postgresql-config.data["postgres-password"]
      db_host           = local.database_host
      db_port           = local.database_port

      argo_database = kubernetes_secret.postgresql-argo.data["database-name"]
      argo_username = kubernetes_secret.postgresql-argo.data["database-username"]
      argo_password = kubernetes_secret.postgresql-argo.data["database-password"]
    }
  )
}

resource "kubectl_manifest" "cosmotechapi_initdb" {
  yaml_body = templatefile("${path.module}/postgress-api-init.yaml",
    {
      namespace         = var.tenant
      postgres_password = kubernetes_secret.postgresql-config.data["postgres-password"]
      db_host           = local.database_host
      db_port           = local.database_port

      # all cosmotech secrets
      cosmotechapi_database        = kubernetes_secret.postgresql-cosmotechapi.data["database-name"]
      cosmotechapi_admin_username  = kubernetes_secret.postgresql-cosmotechapi.data["admin-username"]
      cosmotechapi_admin_password  = kubernetes_secret.postgresql-cosmotechapi.data["admin-password"]
      cosmotechapi_writer_username = kubernetes_secret.postgresql-cosmotechapi.data["writer-username"]
      cosmotechapi_writer_password = kubernetes_secret.postgresql-cosmotechapi.data["writer-password"]
      cosmotechapi_reader_username = kubernetes_secret.postgresql-cosmotechapi.data["reader-username"]
      cosmotechapi_reader_password = kubernetes_secret.postgresql-cosmotechapi.data["reader-password"]
    }
  )
}
