output "database_admin_username" {
  value = local.database_admin_username
}

output "database_admin_password" {
  value = local.database_admin_password
}

output "service_address" {
  value = "${data.kubernetes_resources.services.objects[0].metadata.name}.${var.namespace}.svc.cluster.local:8080/${var.namespace}/${local.cosmotech_run_api_url_suffix}"
}
