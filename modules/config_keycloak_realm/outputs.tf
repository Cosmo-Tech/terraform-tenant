output "keycloak_api_client_id" {
  value = keycloak_openid_client.cosmotech_api.client_id
}

output "keycloak_api_client_secret" {
  value = keycloak_openid_client.cosmotech_api.client_secret
}

output "keycloak_admin_client_id" {
  value = keycloak_openid_client.cosmotech_admin.client_id
}

output "keycloak_admin_client_secret" {
  value = keycloak_openid_client.cosmotech_admin.client_secret
}

output "keycloak_webapp_client_id" {
  value = try(keycloak_openid_client.cosmotech_webapp[0].client_id, null)
}
