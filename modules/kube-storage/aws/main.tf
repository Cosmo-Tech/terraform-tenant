# resource "aws_resourcegroups_group" "rg" {
#   # tags = local.tags

#   name   = var.tenant
#   region = var.region

#   resource_query {
#     query = <<JSON
#       {
#         "ResourceTypeFilters": [
#           "AWS::AllSupported"
#         ],
#         "TagFilters": [
#           {
#             "Key": "rg",
#             "Values": ["${var.tenant}"]
#           }
#         ]
#       }
#     JSON
#   }
# }


# data "aws_availability_zones" "cluster" {
#   region = var.region
#   state  = "available"
# }


resource "aws_ebs_volume" "disk" {
  count = var.cloud_provider == "aws" ? 1 : 0

  # availability_zone = data.aws_availability_zones.cluster.names[0]
  availability_zone = "${var.region}a"
  size              = var.size

  tags = {
    Name = "disk-${var.tenant}-${var.resource}"
  }

  # depends_on = [
  #   aws_resourcegroups_group.rg,
  # ]
}


resource "kubernetes_persistent_volume" "pv" {
  count = var.cloud_provider == "aws" ? 1 : 0

  metadata {
    name = "pv-${var.tenant}-${var.resource}"
  }
  spec {
    capacity = {
      storage = "${aws_ebs_volume.disk[0].size}Gi"
    }
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    # storage_class_name = "gp2"
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.disk[0].id
      }
    }
  }

  depends_on = [
    aws_ebs_volume.disk,
  ]
}


resource "kubernetes_persistent_volume_claim" "pvc" {
  count = var.cloud_provider == "aws" ? 1 : 0

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

