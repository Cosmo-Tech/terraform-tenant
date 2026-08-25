output "tenant_namespace" {
  value = kubernetes_namespace.tenant.metadata[0].name
}

output "image_registry" {
  value = keys(jsondecode(kubernetes_secret.registry_auth.data[".dockerconfigjson"]).auths)[0]
}