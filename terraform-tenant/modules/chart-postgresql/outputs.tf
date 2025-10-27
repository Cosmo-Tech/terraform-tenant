output "database_host" {
  value = local.database_host
}

output "database_port" {
  value = local.database_port
}



output "database_seaweedfs_name" {
  value = kubernetes_secret.postgresql-seaweedfs.data.postgresql-database
}

output "database_seaweedfs_user" {
  value = kubernetes_secret.postgresql-seaweedfs.data.postgresql-username
}

output "database_seaweedfs_secret" {
  value = kubernetes_secret.postgresql-seaweedfs.metadata[0].name
}



output "database_argo_name" {
  value = kubernetes_secret.postgresql-argo.data.database-name
}

output "database_argo_user" {
  value = kubernetes_secret.postgresql-argo.data.database-username
}

output "database_argo_secret" {
  value = kubernetes_secret.postgresql-argo.metadata[0].name
}



output "database_cosmotech_username_reader" {
  value = kubernetes_secret.postgresql-cosmotechapi.data.username-reader
}

output "database_cosmotech_password_reader" {
  value = kubernetes_secret.postgresql-cosmotechapi.data.password-reader
}

output "database_cosmotech_username_writer" {
  value = kubernetes_secret.postgresql-cosmotechapi.data.username-writer
}

output "database_cosmotech_password_writer" {
  value = kubernetes_secret.postgresql-cosmotechapi.data.password-writer
}

output "database_cosmotech_username_admin" {
  value = kubernetes_secret.postgresql-cosmotechapi.data.username-admin
}

output "database_cosmotech_password_admin" {
  value = kubernetes_secret.postgresql-cosmotechapi.data.password-admin
}
