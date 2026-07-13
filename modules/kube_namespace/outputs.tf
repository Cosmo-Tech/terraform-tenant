output "tenant" {
  value = kubernetes_namespace.tenant.metadata[0].name
}

output "image_registry" {
  value = keys(jsondecode(kubernetes_secret.registry_auth["chainguard"].data[".dockerconfigjson"]).auths)[0]
}
