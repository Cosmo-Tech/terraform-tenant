locals {
  chart_values = {
    "PERSISTENCE_SIZE"          = var.size
    "PERSISTENCE_PVC"           = var.pvc
    "PERSISTENCE_STORAGE_CLASS" = var.pvc_storage_class
    "POSTGRESQL_SECRET_CONFIG"  = kubernetes_secret.postgresql-config.metadata[0].name
  }

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
    kubernetes_secret.postgresql-seaweedfs,
  ]
}

# Goal of this Job is just to init stuff in the main PostgreSQL
# Notes:
#   To be sure having a working 'psql' command, the job is directly installed from an official PostgreSQL image
#   The used image is Debian because Kubernetes DNS forces us to have DNS based on glibc & not musl (like in Alpine)
#   See https://guillaume.fenollar.fr/blog/kubernetes-dns-options-ndots-glibc-musl/ for more details
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
          name  = "postgresql-initdb"
          image = "postgres:17-trixie"
          command = [
            "/bin/sh",
            "-c",
          ]
          args = [
            <<EOT
              # DNS doesn't work by default in postgres image
              apt update && apt install -y dnsutils 
  
              export PGPASSWORD='${kubernetes_secret.postgresql-config.data.postgres-password}'
              export PGHOST='${local.database_host}'
              export PGPORT='${local.database_port}'

              # SeaweedFS init
              psql -U postgres -c "
                CREATE ROLE ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-username} WITH LOGIN PASSWORD '${kubernetes_secret.postgresql-seaweedfs.data.postgresql-password}';
              "
              psql -U postgres -c "
                CREATE DATABASE ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-database} WITH OWNER ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-username};
              "
                # Set seaweedfs password to create table
                export PGPASSWORD='${kubernetes_secret.postgresql-seaweedfs.data.postgresql-password}'
                psql -U ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-username} -d ${kubernetes_secret.postgresql-seaweedfs.data.postgresql-database} -c "
                  CREATE TABLE IF NOT EXISTS filemeta (
                    dirhash     BIGINT,
                    name        VARCHAR(65535),
                    directory   VARCHAR(65535),
                    meta        bytea,
                    PRIMARY KEY (dirhash, name)
                  );
                "

              # Set back the postgres password
              # export PGPASSWORD='${kubernetes_secret.postgresql-config.data.postgres-password}'

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
        dns_policy     = "ClusterFirst"
        restart_policy = "Never"
      }
    }
    backoff_limit              = 0
    ttl_seconds_after_finished = 0
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
