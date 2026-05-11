# # To use images directly from inside Kubernetes (like a sub image in a chart for example), we need to authenticate to the Helm registry

# resource "kubernetes_secret" "registry_authentication" {
#   metadata {
#     namespace = var.tenant
#     name      = "registry-authentication"
#   }

#   data = {
#     "docker-server" : "cgr.dev",
#     "docker-username" : var.tenant,
#     "docker-password" : random_password.password.result,
#   }

#   type = "Opaque"
# }
