locals {
  chart_values = {
    "POSTGRESQL_INITDB_SECRET"      = "var.postgresql_initdb_secret_name"
    "MONITORING_NAMESPACE"          = "var.monitoring_namespace"
    "POSTGRESQL_SECRET_NAME"        = "var.postgresql_secret_name"
    "POSTGRESQL_PASSWORD"           = "data.kubernetes_secret.postgres_config.data.postgres-password"
    "POSTGRESQL_DATABASE"           = "data.kubernetes_secret.postgres_config.data.database-name"
    "PERSISTENCE_SIZE"              = "var.persistence_size"
    "POSTGRESQL_EXISTING_PVC_NAME"  = "var.postgresql_existing_pvc_name"
    "POSTGRESQL_STORAGE_CLASS_NAME" = "var.postgresql_pvc_storage_class_name"
  }
  # seaweedfs_username        = var.seaweedfs_username
  # seaweedfs_password_secret = "${var.postgresql_secret_name}-seaweedfs"
  # seaweedfs_database        = var.seaweedfs_database

  resource_name = "postgresql-${var.tenant_namespace}"
}



resource "azurerm_managed_disk" "postgresql_disk" {
  name                 = "disk-${var.tenant_namespace}-postgresql"
  location             = var.zz_azure_aks_rg_region
  resource_group_name  = var.zz_azure_aks_rg_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 8

  depends_on = [
    var.tenant_namespace,
  ]
}


# resource "kubernetes_persistent_volume" "postgresql" {
#   metadata {
#     name = "pv-${local.resource_name}"
#   }
#   spec {
#     capacity = {
#       storage = "8Gi"
#     }
#     access_modes = ["ReadWriteOnce"]
#     persistent_volume_source {
#       vsphere_volume {
#         volume_path = "/subscriptions/${var.zz_azure_subscription_id}/resourceGroups/${var.zz_azure_aks_rg_name}/providers/Microsoft.Compute/disks/${azurerm_managed_disk.postgresql_disk.name}"
#       }
#     }
#   }

#   depends_on = [
#     azurerm_managed_disk.postgresql_disk,
#   ]
# }



resource "kubernetes_persistent_volume" "postgresql" {
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
    azurerm_managed_disk.postgresql_disk,
  ]
}


# resource "kubernetes_persistent_volume" "pv_postgres_master" {
#   count = var.pv_postgres_provider == "azure" ? 1 : 0
#   metadata {
#     name = "pv-${local.resource_name}"
#   }
#   spec {
#     capacity = {
#       storage = "${var.pv_postgres_storage_gbi}Gi"
#     }
#     access_modes       = ["ReadWriteOnce"]
#     storage_class_name = var.pv_postgres_storage_class_name
#     persistent_volume_source {
#       azure_disk {
#         caching_mode  = "None"
#         data_disk_uri = var.pv_postgres_disk_source_existing ? data.azurerm_managed_disk.disk_managed_postgres.0.id : azurerm_managed_disk.postgres_master.0.id
#         disk_name     = var.pv_postgres_disk_source_existing ? data.azurerm_managed_disk.disk_managed_postgres.0.name : azurerm_managed_disk.postgres_master.0.name
#         kind          = "Managed"
#       }
#     }
#   }

#   depends_on = [
#     azurerm_managed_disk.postgresql_disk,
#   ]
# }



# resource "kubernetes_persistent_volume_claim" "postgresql" {
#   metadata {
#     name = "pvc-${local.resource_name}"
#     namespace = var.tenant_namespace
#   }
#   spec {
#     access_modes       = [var.pvc_minio_storage_accessmode]
#     storage_class_name = var.pvc_minio_storage_class_name
#     resources {
#       requests = {
#         storage = var.pvc_minio_storage_gbi
#       }
#     }
#     volume_name = kubernetes_persistent_volume.postgresql.name
#   }

#   depends_on = [
#     kubernetes_persistent_volume.postgresql,
#   ]
# }



resource "helm_release" "postgresql" {
  namespace    = var.tenant_namespace
  name       = local.resource_name
  repository = "https://charts.bitnami.com/bitnami"
  chart       = "postgresql"
  version     = "11.6.12"
  reset_values = true
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  depends_on = [
    # var.tenant_namespace,
    kubernetes_persistent_volume.postgresql,
  ]


  replace = true
}
