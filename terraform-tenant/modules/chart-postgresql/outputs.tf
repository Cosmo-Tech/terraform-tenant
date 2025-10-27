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

