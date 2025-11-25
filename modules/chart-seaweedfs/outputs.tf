output "s3_host" {
  value = local.s3_host
}

output "s3_port" {
  value = local.s3_port
}

output "s3_secret" {
  value = kubernetes_secret.s3_secret.metadata[0].name
}

output "s3_secret_key_argo_workflows_username" {
  value = local.s3_secret_key_argo_workflows_username
}

output "s3_secret_key_argo_workflows_password" {
  value = local.s3_secret_key_argo_workflows_password
}

output "s3_argo_workflows_bucket" {
  value = local.s3_argo_workflows_bucket
}

output "s3_secret_key_cosmotech_api_username" {
  value = local.s3_secret_key_cosmotech_api_username
}

output "s3_secret_key_cosmotech_api_password" {
  value = local.s3_secret_key_cosmotech_api_password
}

output "s3_cosmotech_api_bucket" {
  value = local.s3_cosmotech_api_bucket
}
