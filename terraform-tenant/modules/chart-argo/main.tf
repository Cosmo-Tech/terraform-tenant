locals {
  chart_values = {
    "ARGO_SERVICE_ACCOUNT"        = "test"
    "S3_ENDPOINT"                 = "var.s3_endpoint"
    "S3_BUCKET_NAME"              = "var.s3_bucket_name"
    "S3_CREDENTIALS_SECRET"       = "var.s3_credentials_secret"
    "S3_USERNAME_KEY"             = "var.s3_username_key"
    "S3_PASSWORD_KEY"             = "var.s3_password_key"
    "POSTGRES_RELEASE_NAME"       = "var.postgres_release_name"
    "ARGO_DATABASE"               = "var.argo_database"
    "ARGO_POSTGRESQL_USER"        = "var.postgres_argo_user"
    "ARGO_POSTGRESQL_SECRET_NAME" = "var.argo_postgresql_secret_name"
  }
  service_account = "${var.tenant_name}-argo-service-account"
}



resource "helm_release" "argo_workflows" {


  namespace    = var.tenant_name

  name       = "argo-workflows"
  repository = "https://charts.bitnami.com/bitnami"
  chart       = "argo-workflows"
  version     = "9.1.6"

  reset_values = true

  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  depends_on = [
    var.tenant_name,
  ]
}
