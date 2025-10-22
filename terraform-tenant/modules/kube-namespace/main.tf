resource "kubernetes_namespace" "tenant" {
  metadata {
    name = local.main_name
  }
}

resource "random_password" "password" {
  length           = 40
  min_lower = 5
  min_upper = 5
  min_numeric = 5 
  min_special = 5
}


resource "kubernetes_secret" "postgresql" {
  metadata {
    name      = "cosmotech-postgresql"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

 data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

 type = "Opaque"
}



resource "kubernetes_secret" "seaweedfs" {
  metadata {
    name      = "cosmotech-seaweedfs"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

 data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

 type = "Opaque"
}


resource "kubernetes_secret" "argo" {
  metadata {
    name      = "cosmotech-argo"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

 data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

 type = "Opaque"
}


resource "kubernetes_secret" "rabbitmq" {
  metadata {
    name      = "cosmotech-rabbitmq"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

 data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

 type = "Opaque"
}



resource "kubernetes_secret" "redis" {
  metadata {
    name      = "cosmotech-redis"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

 data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

 type = "Opaque"
}


resource "kubernetes_secret" "harbor" {
  metadata {
    name      = "cosmotech-harbor"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

 data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

 type = "Opaque"
}


resource "kubernetes_secret" "keycloak" {
  metadata {
    name      = "cosmotech-keycloak"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }

 data = {
    "todo1" = random_password.password.result
    "todo2" = random_password.password.result
    "todo3" = random_password.password.result
  }

 type = "Opaque"
}





# postgres_postgresql_password
# argo_postgresql_password
# postgresql_reader_password
# postgresql_writer_password
# postgresql_admin_password
# postgresql_data
# postgresql-initdb
# postgres-config
# rabbitmq_admin_password
# rabbitmq_listener_password
# rabbitmq_sender_password
# rabbitmq_load_data
# rabbitmq-secret
# rabbitmq_load_definition
# redis_admin_password
# redis_admin_password
# seaweedfs_argo_workflows_password
# seaweedfs_cosmotech_api_password
# s3_credentials
# s3_auth_config
# postgres-seaweedfs-config
# acr_login_password
# kusto_account_password
# storage_account_password
# keycloak_client_secret
# platform_client_secret