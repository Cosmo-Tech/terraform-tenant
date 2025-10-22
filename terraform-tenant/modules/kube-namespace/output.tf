output "tenant_namespace" {
  value = kubernetes_namespace.tenant.metadata[0].name
}