output "database_host" {
  value = local.database_host
}

output "database_port" {
  value = local.database_port
}

output "postgresql_secret" {
  value = kubernetes_secret.postgresql-config.metadata[0].name
}
