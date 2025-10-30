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
    namespace = var.tenant
    name      = "postgresql-config"
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
    namespace = var.tenant
    name      = "postgresql-seaweedfs"
  }

  data = {
    "postgresql-database" = "seaweedfs"
    "postgresql-username" = "seaweedfs"
    "postgresql-password" = random_password.password[2].result
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


# Specific secret containing Cosmo Tech API database informations
resource "kubernetes_secret" "postgresql-cosmotechapi" {
  type = "Opaque"

  metadata {
    namespace = var.tenant
    name      = "postgresql-cosmotechapi"
  }

  data = {
    "admin-username"  = "cosmotech_api_admin"
    "admin-password"  = random_password.password[4].result
    "reader-username" = "cosmotech_api_reader"
    "reader-password" = random_password.password[5].result
    "writer-username" = "cosmotech_api_writer"
    "writer-password" = random_password.password[6].result
    "database-name"   = "cosmotech"
  }
}


resource "helm_release" "postgresql" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "16.7.27"
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
    kubernetes_secret.postgresql-argo,
  ]
}


# Goal of this Job is just to init stuff in the main PostgreSQL
# Notes:
#   - This is done from a job to be able query PostgreSQL from its DNS ("pod.namespace.svc.cluster.local")
#   - To be sure having a working 'psql' command, the job is directly installed from an official PostgreSQL image
#   - The used image is Debian because Kubernetes DNS forces us to have DNS based on glibc & not musl (like in Alpine)
#       > See https://guillaume.fenollar.fr/blog/kubernetes-dns-options-ndots-glibc-musl/ for more details
resource "kubernetes_job" "initdb" {
  metadata {
    namespace = var.tenant
    name      = "postgresql-initdb"
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

              export PGPASSWORD='${kubernetes_secret.postgresql-config.data["postgres-password"]}'
              export PGHOST='${local.database_host}'
              export PGPORT='${local.database_port}'



              # Function to check if database already exists
              # Usage: database_exists <name>
              database_exists() {
                local dbname="$1"
                if [ "$(psql -U postgres -c "SELECT datname FROM pg_database" | grep -w $dbname)" = "" ]; then
                  echo "false"
                fi
              }



              ## >>> Argo
              argo_database='${kubernetes_secret.postgresql-argo.data["database-name"]}'
              argo_username='${kubernetes_secret.postgresql-argo.data["database-username"]}'
              argo_password='${kubernetes_secret.postgresql-argo.data["database-password"]}'
              if [ "$(database_exists $argo_database)" = "false" ]; then
                psql -U postgres -c "CREATE ROLE $argo_username WITH LOGIN PASSWORD '$argo_password';"
                psql -U postgres -c "CREATE DATABASE $argo_database WITH OWNER $argo_username;"
              else
                  echo "database $argo_database already exists, skipping"
              fi



              ## >>> Cosmo Tech API
              cosmotechapi_database='${kubernetes_secret.postgresql-cosmotechapi.data["database-name"]}'
              cosmotechapi_admin_username='${kubernetes_secret.postgresql-cosmotechapi.data["admin-username"]}'
              cosmotechapi_admin_password='${kubernetes_secret.postgresql-cosmotechapi.data["admin-password"]}'
              cosmotechapi_writer_username='${kubernetes_secret.postgresql-cosmotechapi.data["writer-username"]}'
              cosmotechapi_writer_password='${kubernetes_secret.postgresql-cosmotechapi.data["writer-password"]}'
              cosmotechapi_reader_username='${kubernetes_secret.postgresql-cosmotechapi.data["reader-username"]}'
              cosmotechapi_reader_password='${kubernetes_secret.postgresql-cosmotechapi.data["reader-password"]}'

              if [ "$(database_exists $cosmotechapi_database)" = "false" ]; then
                psql -U postgres -c "CREATE ROLE $cosmotechapi_reader_username WITH LOGIN PASSWORD '$cosmotechapi_reader_password';"
                psql -U postgres -c "CREATE ROLE $cosmotechapi_writer_username WITH LOGIN PASSWORD '$cosmotechapi_writer_password';"
                psql -U postgres -c "CREATE ROLE $cosmotechapi_admin_username WITH LOGIN PASSWORD '$cosmotechapi_admin_password' CREATEDB;"
                psql -U postgres -c "CREATE DATABASE $cosmotechapi_database WITH OWNER $cosmotechapi_admin_username;"

                export PGPASSWORD="$cosmotechapi_admin_password" # Set cosmo admin password to use cosmo admin user
                psql -U $cosmotechapi_admin_username -c "CREATE SCHEMA inputs AUTHORIZATION $cosmotechapi_writer_username;"
                psql -U $cosmotechapi_admin_username -c "CREATE SCHEMA outputs AUTHORIZATION $cosmotechapi_writer_username;"
                psql -U $cosmotechapi_admin_username -c "GRANT USAGE ON SCHEMA inputs TO $cosmotechapi_reader_username;"
                psql -U $cosmotechapi_admin_username -c "GRANT USAGE ON SCHEMA outputs TO $cosmotechapi_reader_username;"
              else
                  echo "database $cosmotechapi_database already exists, skipping"
              fi



              ## >>> SeaweedFS
              seaweedfs_database='${kubernetes_secret.postgresql-seaweedfs.data["postgresql-database"]}'
              seaweedfs_username='${kubernetes_secret.postgresql-seaweedfs.data["postgresql-username"]}'
              seaweedfs_password='${kubernetes_secret.postgresql-seaweedfs.data["postgresql-password"]}'
              if [ "$(database_exists $seaweedfs_database)" = "false" ]; then
                psql -U postgres -c "CREATE ROLE $seaweedfs_username WITH LOGIN PASSWORD '$seaweedfs_password';"
                psql -U postgres -c "CREATE DATABASE $seaweedfs_database WITH OWNER $seaweedfs_username;"

                export PGPASSWORD="$seaweedfs_password" # Set seaweedfs password to user seaweedfs user
                psql -U $seaweedfs_username -d $seaweedfs_database -c "
                  CREATE TABLE IF NOT EXISTS filemeta (
                    dirhash     BIGINT,
                    name        VARCHAR(65535),
                    directory   VARCHAR(65535),
                    meta        bytea,
                    PRIMARY KEY (dirhash, name)
                  );
                "
              else
                  echo "database $seaweedfs_database already exists, skipping"
              fi


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
