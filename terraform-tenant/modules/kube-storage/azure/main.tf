resource "azurerm_managed_disk" "disk" {
  name                 = "disk-${var.tenant}-${var.resource}"
  location             = var.zz_azure_aks_rg_region
  resource_group_name  = var.zz_azure_aks_rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.size

  depends_on = [
    var.tenant,
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
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "cosmotech-retain"
    persistent_volume_source {
      azure_disk {
        caching_mode  = "None"
        data_disk_uri = "/subscriptions/${var.zz_azure_subscription_id}/resourceGroups/${var.zz_azure_aks_rg_name}/providers/Microsoft.Compute/disks/${azurerm_managed_disk.disk.name}"
        disk_name     = "pv-${var.tenant}-${var.resource}"
        kind          = "Managed"
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
    access_modes       = ["ReadWriteOnce"]
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

