output "tenant_namespace" {
  value = local.tenant_namespace
}

output "business_webapp_url" {
  value = one(module.chart_cosmotech_business_webapp[*].webapp_url)
}

output "powerbi_app_client_id" {
  value = one(module.config_powerbi_app[*].out_app_powerbi_client_id)
}