output "pvc" {
  value = kubernetes_persistent_volume_claim.pvc[0].metadata[0].name
}
