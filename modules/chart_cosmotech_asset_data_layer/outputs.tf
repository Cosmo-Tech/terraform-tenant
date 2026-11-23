output "service_address" {
  value = length(data.kubernetes_resources.services.objects) > 0 ? "${data.kubernetes_resources.services.objects[0].metadata.name}.${var.namespace}.svc.cluster.local:8080${local.url_suffix}" : "known_after_apply"
}
