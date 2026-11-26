output "out_app_powerbi_client_id" {
  value = azuread_application.powerbi.client_id
}

output "out_app_powerbi_client_secret" {
  sensitive = true
  value     = azuread_application_password.powerbi_password.value
}