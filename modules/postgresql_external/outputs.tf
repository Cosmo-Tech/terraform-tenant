output "database_host" {
  value = var.external_postgres_host
}

output "database_port" {
  value = var.external_postgres_port
}

output "database_name" {
  value = postgresql_database.tenant.name
}

output "admin_username" {
  value = postgresql_role.admin.name
}

output "writer_username" {
  value = postgresql_role.writer.name
}

output "reader_username" {
  value = postgresql_role.reader.name
}
