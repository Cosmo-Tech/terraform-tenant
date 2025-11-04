output "tenant" {
  value = kubernetes_namespace.tenant.metadata[0].name
}