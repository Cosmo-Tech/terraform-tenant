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

