# resource "azurerm_resource_group" "rg" {
#   name     = var.tenant
#   location = var.region
# }


resource "azurerm_managed_disk" "disk" {
  name                 = "disk-${var.tenant}-${var.resource}"
  location             = var.region
  # resource_group_name  = azurerm_resource_group.rg.name
  resource_group_name = var.resource_group
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.size

  depends_on = [
    var.tenant,
    # azurerm_resource_group.rg,
  ]
}


resource "kubernetes_persistent_volume" "pv" {
  metadata {
    name = "pv-${var.tenant}-${var.resource}"
  }
  spec {
    capacity = {
      storage = "${azurerm_managed_disk.disk.disk_size_gb}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    # storage_class_name = "cosmotech-retain"
    storage_class_name = var.storage_class_name
    persistent_volume_source {
      azure_disk {
        caching_mode  = "None"
        data_disk_uri = azurerm_managed_disk.disk.id
        # data_disk_uri = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Compute/disks/${azurerm_managed_disk.disk.name}"
        disk_name = "pv-${var.tenant}-${var.resource}"
        kind      = "Managed"
      }
    }
  }

  depends_on = [
    azurerm_managed_disk.disk,
  ]
}


resource "kubernetes_persistent_volume_claim" "pvc" {

  metadata {
    namespace = var.tenant
    name      = "pvc-${var.tenant}-${var.resource}"
  }
  spec {
    access_modes       = kubernetes_persistent_volume.pv.spec[0].access_modes
    storage_class_name = kubernetes_persistent_volume.pv.spec[0].storage_class_name
    resources {
      requests = {
        storage = "${kubernetes_persistent_volume.pv.spec[0].capacity.storage}"
      }
    }
    volume_name = kubernetes_persistent_volume.pv.metadata[0].name
  }

  depends_on = [
    kubernetes_persistent_volume.pv,
  ]
}

