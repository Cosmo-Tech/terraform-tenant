locals {
  chart_values = {
    "PERSISTENCE_SIZE"          = var.size
    "PERSISTENCE_PVC"           = var.pvc
    "PERSISTENCE_STORAGE_CLASS" = var.pvc_storage_class
    "RELEASE"                   = var.release
    "SECRET_CREDENTIALS"        = kubernetes_secret.credentials.metadata[0].name
    "SECRET_LOAD_DEFINITION"    = kubernetes_secret.load_definition.metadata[0].name
  }

  load_definition_values = {
    "USER_ADMIN" = kubernetes_secret.credentials.data.admin-username
    "PASSWORD_ADMIN" = kubernetes_secret.credentials.data.admin-password
    "USER_LISTENER" = kubernetes_secret.credentials.data.listener-username
    "PASSWORD_LISTENER" = kubernetes_secret.credentials.data.listener-password
    "USER_SENDER" = kubernetes_secret.credentials.data.sender-username
    "PASSWORD_SENDER" = kubernetes_secret.credentials.data.sender-password
  }
}


resource "random_password" "password" {
  count = 10

  length      = 40
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
  special     = false
}


# resource "kubernetes_secret" "admin" {
#   metadata {
#     namespace = var.tenant
#     name      = "${var.release}-admin"
#   }

#   data = {
#     "password" = random_password.password[0].result
#   }

#   type = "Opaque"
# }


resource "kubernetes_secret" "credentials" {
  metadata {
    namespace = var.tenant
    name      = "${var.release}-credentials"
  }

  data = {
    admin-username    = "admin"
    admin-password    = random_password.password[1].result
    listener-username = "cosmotech_api_listener"
    listener-password = random_password.password[2].result
    sender-username   = "cosmotech_run_sender"
    sender-password   = random_password.password[3].result
  }

  type = "Opaque"
}


resource "kubernetes_secret" "load_definition" {
  metadata {
    namespace = var.tenant
    name      = "${var.release}-load-definition"
  }

  data = {
    "load_definition.json" = templatefile("${path.module}/load_definition.json", local.load_definition_values)
  }
}


# resource "kubernetes_secret" "load_definition" {
#   metadata {
#     namespace = var.tenant
#     name      = "${var.release}-load-definition"
#   }

#   data = {
#     "load_definition.json" = jsonencode({
#       users = [
#         {
#           "name" : "${kubernetes_secret.credentials.data.admin-username}"
#           "password" : "${kubernetes_secret.credentials.data.admin-password}"
#           "tags" : "administrator"
#         },
#         {
#           "name" : "${kubernetes_secret.credentials.data.listener-username}"
#           "password" : "${kubernetes_secret.credentials.data.listener-password}"
#           "tags" : ""
#         },
#         {
#           "name" : "${kubernetes_secret.credentials.data.sender-username}"
#           "password" : "${kubernetes_secret.credentials.data.sender-password}"
#           "tags" : ""
#         }
#       ]
#       vhosts = [
#         {
#           "name" : "/"
#         }
#       ]
#       permissions = [
#         {
#           "name" : "${kubernetes_secret.credentials.data.admin-username}"
#           "vhost" : "/"
#           "configure" : ".*"
#           "write" : ".*"
#           "read" : ".*"
#         },
#         {
#           "name" : "${kubernetes_secret.credentials.data.listener-username}"
#           "vhost" : "/"
#           "configure" : ".*"
#           "write" : ".*"
#           "read" : ".*"
#         },
#         {
#           "name" : "${kubernetes_secret.credentials.data.sender-username}"
#           "vhost" : "/"
#           "configure" : ".*"
#           "write" : ".*"
#           "read" : ".*"
#         }
#       ]
#     })
#   }

#   type = "Opaque"
# }




resource "helm_release" "rabbitmq" {
  namespace  = var.tenant
  name       = var.release
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  version    = "16.0.14"
  # version    = "13.0.3"
  values = [
    templatefile("${path.module}/values.yaml", local.chart_values)
  ]

  reset_values = true
  replace      = true
  force_update = true

  depends_on = [
    var.tenant,
    var.pvc,
    # kubernetes_secret.load_definition,
    kubernetes_secret.credentials,
  ]
}
