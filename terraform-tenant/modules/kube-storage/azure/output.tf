output "pvc" {
  value = kubernetes_persistent_volume_claim.pvc.name
}