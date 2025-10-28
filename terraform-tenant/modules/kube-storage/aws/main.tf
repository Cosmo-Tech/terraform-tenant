data "aws_availability_zones" "cluster" {
  region = var.zz_aws_cluster_region
  state  = "available"
}


resource "aws_ebs_volume" "disk" {
  availability_zone = data.aws_availability_zones.cluster
  size              = var.size

  tags = {
    Name = "disk-${var.tenant}-${var.resource}"
  }
}


resource "kubernetes_persistent_volume" "pv" {
  metadata {
    name = "pv-${var.tenant}-${var.resource}"
  }
  spec {
    capacity = {
      storage = "${aws_ebs_volume.disk.size}Gi"
    }
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    persistent_volume_source {

      aws_elastic_block_store {
        volume_id = aws_ebs_volume.disk.id
      }
    }
  }

  depends_on = [
    aws_ebs_volume.disk,
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

