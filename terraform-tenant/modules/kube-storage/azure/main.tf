locals {
  for_each = var.storage

  resource_name = "${var.tenant_namespace}-${each.value.associated_resource}"
}



resource "azurerm_managed_disk" "disk" {
  for_each = var.storage

  name                 = "disk-${local.resource_name}"
  location             = var.zz_azure_aks_rg_region
  resource_group_name  = var.zz_azure_aks_rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8

  depends_on = [
    var.tenant_namespace,
  ]
}



resource "kubernetes_persistent_volume" "pv" {
  metadata {
    name = "pv-${local.resource_name}"
  }
  spec {
    capacity = {
      storage = "${azurerm_managed_disk.postgresql_disk.disk_size_gb}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      azure_disk {
        caching_mode  = "None"
        data_disk_uri = "/subscriptions/${var.zz_azure_subscription_id}/resourceGroups/${var.zz_azure_aks_rg_name}/providers/Microsoft.Compute/disks/${azurerm_managed_disk.postgresql_disk.name}"
        disk_name     = "pv-${local.resource_name}"
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
    name = "pvc-${local.resource_name}"
    namespace = var.tenant_namespace
  }
  spec {
    access_modes       = [var.pvc_minio_storage_accessmode]
    storage_class_name = var.pvc_minio_storage_class_name
    resources {
      requests = {
        storage = var.pvc_minio_storage_gbi
      }
    }
    volume_name = kubernetes_persistent_volume.postgresql.name
  }

  depends_on = [
    kubernetes_persistent_volume.pvc,
  ]
}


