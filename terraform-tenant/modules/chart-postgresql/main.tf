locals {
  chart_values = {
    "PERSISTENCE_SIZE"          = var.size
    "PERSISTENCE_PVC"           = var.pvc
    "PERSISTENCE_STORAGE_CLASS" = var.pvc_storage_class
    "POSTGRESQL_SECRET_CONFIG"  = kubernetes_secret.postgresql-config.metadata[0].name
  }
  #   "POSTGRESQL_PASSWORD"  = kubernetes_secret.postgresql-config.data.postgres-password
  # }
  #   "POSTGRESQL_SECRET_INITDB"  = kubernetes_secret.postgresql-initdb.metadata[0].name
  # }


  # initdb_values = {
  #   "SEAWEEDFS_DATABASE" = kubernetes_secret.postgresql-seaweedfs.data.postgresql-database
  #   "SEAWEEDFS_USERNAME" = kubernetes_secret.postgresql-seaweedfs.data.postgresql-username
  #   "SEAWEEDFS_PASSWORD" = kubernetes_secret.postgresql-seaweedfs.data.postgresql-password
  # }

  database_host = "${helm_release.postgresql.name}.${helm_release.postgresql.namespace}.svc.cluster.local"
  database_port = "5432"
}


# Just generate an amount of secured passwords
resource "random_password" "password" {
  count = 10

  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  # min_special = 5

  special = false
}


# Main secret containing PostgreSQL informations
# The key "postgres-password" is a common value that most of charts uses by default
resource "kubernetes_secret" "postgresql-config" {
  type = "Opaque"

  metadata {
    name      = "postgresql-config"
    namespace = var.tenant
  }

  data = {
    # "cosmotech-api-admin-password" = random_password.password.result
    # "cosmotech-api-admin-username" = cosmotech_api_admin
    # "cosmotech-api-reader-password" = random_password.password.result
    # "cosmotech-api-reader-username" = cosmotech_api_reader
    # "cosmotech-api-writer-password" = random_password.password.result
    # "cosmotech-api-writer-username" = cosmotech_api_writer
    # "database-password" = random_password.password.result
    # "postgres-password" = random_password.password.result
    # "postgres-username" = "postgres"
    "postgres-password" = random_password.password[1].result
  }

  depends_on = [
    random_password.password,
  ]
}


# # # Specific secret containing script to initialize PostgreSQL databases
# # Must be a secret because it contains sensitives data
# resource "kubernetes_secret" "postgresql-initdb" {
#   type = "Opaque"

#   metadata {
#     name      = "postgresql-initdb"
#     namespace = var.tenant
#   }

#   data = {
#     "001-initdb.sql" = templatefile("${path.module}/001-initdb.sql", local.initdb_values)
#   }
# }


# Specific secret containing SeadweedFS database informations
# SeaweedFS chart requires to have a "postgresql-password" key in its secret
resource "kubernetes_secret" "postgresql-seaweedfs" {
  type = "Opaque"

  metadata {
    name      = "postgresql-seaweedfs"
    namespace = var.tenant
  }

  data = {
    "postgresql-database" = "seaweedfs"
    "postgresql-username" = "seaweedfs"
    "postgresql-password" = random_password.password[2].result
  }
}


resource "helm_release" "postgresql" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  # version    = "18.1.1"
  version = "16.7.27"
  # version = "11.6.12"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
    var.pvc,
    kubernetes_secret.postgresql-config,
    # kubernetes_secret.postgresql-initdb,
    kubernetes_secret.postgresql-seaweedfs,
  ]
}

resource "kubernetes_job" "initdb" {
  metadata {
    name      = "postgresql-initdb"
    namespace = var.tenant
  }
  spec {
    template {
      metadata {
        labels = {
          "networking/traffic-allowed" = "yes"
        }
      }
      spec {
        container {
          name    = "postgresql-initdb"
          image   = "postgres:17-trixie" # https://guillaume.fenollar.fr/blog/kubernetes-dns-options-ndots-glibc-musl/
          command = [
            "/bin/sh",
            "-c",
          ]
          args = [
            <<EOT
              # dns doesnt work well by default in postgres image
              apt update && apt install -y dnsutils 
  
              export PGPASSWORD='${kubernetes_secret.postgresql-config.data.postgres-password}'
              export PGHOST='${local.database_host}'
              export PGPORT='${local.database_port}'

              psql -U postgres -c "
                CREATE ROLE ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-username} WITH LOGIN PASSWORD '${kubernetes_secret.postgresql-seaweedfs.data.postgresql-password}';
              "

              psql -U postgres -c "
                CREATE DATABASE ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-database} WITH OWNER ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-username};
              "
              
              psql -U postgres -d ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-username} -c "
                CREATE TABLE IF NOT EXISTS filemeta (
                  dirhash     BIGINT,
                  name        VARCHAR(65535),
                  directory   VARCHAR(65535),
                  meta        bytea,
                  PRIMARY KEY (dirhash, name)
                );
              "

              # sleep 80000000

              exit
            EOT
          ]
        }
        toleration {
          key      = "vendor"
          operator = "Equal"
          value    = "cosmotech"
          effect   = "NoSchedule"
        }
        node_selector = {
          "cosmotech.com/tier" = "services",
        }
        
        dns_policy = "ClusterFirst"


        restart_policy = "Never"
      }
    }
    backoff_limit = 0
  }
  wait_for_completion = true
  timeouts {
    create = "30s"
    update = "30s"
  }

  depends_on = [
    helm_release.postgresql,
  ]
}
