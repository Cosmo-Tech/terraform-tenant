output "pvc" {
  value = kubernetes_persistent_volume_claim.pvc.metadata[0].name
}

output "pvc_storage_class" {
  value = kubernetes_persistent_volume_claim.pvc.spec[0].storage_class_name
}

output "size" {
  value = azurerm_managed_disk.disk.disk_size_gb
}