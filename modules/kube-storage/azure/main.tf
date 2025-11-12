# resource "azurerm_resource_group" "rg" {
#   name     = var.tenant
#   location = var.region
# }


# data "azurerm_kubernetes_cluster" "cluster" {
#   name                = var.cluster_name
#   resource_group_name = var.cluster_name
# }

# # Resource group that hosts disks
# # It must be the same resource group that contains nodes, otherwise disks won't be attached to nodes and pods will never start
# data "azurerm_resource_group" "rg" {
#   name = data.azurerm_kubernetes_cluster.cluster.node_resource_group
# }


# Resource group that hosts disks
# It must be the same resource group that contains nodes, otherwise disks won't be attached to nodes and pods will never start
data "kubernetes_nodes" "db" {
  metadata {
    labels = {
      "cosmotech.com/tier" = "db"
    }
  }
}

resource "azurerm_managed_disk" "disk" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name     = "disk-${var.tenant}-${var.resource}"
  location = var.region
  # resource_group_name  = azurerm_resource_group.rg.name
  # resource_group_name  = var.resource_group
  # resource_group_name  = data.azurerm_resource_group.rg
  # resource_group_name  = data.kubernetes_nodes.db.metadata[0].labels["kubernetes.azure.com/cluster"]
  resource_group_name  = [for node in data.kubernetes_nodes.db.nodes : node.metadata.0.labels].0["kubernetes.azure.com/cluster"]
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.size

  depends_on = [
    var.tenant,
    # azurerm_resource_group.rg,
  ]
}


resource "kubernetes_persistent_volume" "pv" {
  count = var.cloud_provider == "azure" ? 1 : 0

  metadata {
    name = "pv-${var.tenant}-${var.resource}"
  }
  spec {
    capacity = {
      storage = "${azurerm_managed_disk.disk[0].disk_size_gb}Gi"
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    persistent_volume_source {
      azure_disk {
        caching_mode  = "None"
        data_disk_uri = azurerm_managed_disk.disk[0].id
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
  count = var.cloud_provider == "azure" ? 1 : 0

  metadata {
    namespace = var.tenant
    name      = "pvc-${var.tenant}-${var.resource}"
  }
  spec {
    access_modes       = kubernetes_persistent_volume.pv[0].spec[0].access_modes
    storage_class_name = kubernetes_persistent_volume.pv[0].spec[0].storage_class_name
    resources {
      requests = {
        storage = "${kubernetes_persistent_volume.pv[0].spec[0].capacity.storage}"
      }
    }
    volume_name = kubernetes_persistent_volume.pv[0].metadata[0].name
  }

  depends_on = [
    kubernetes_persistent_volume.pv[0],
  ]
}

