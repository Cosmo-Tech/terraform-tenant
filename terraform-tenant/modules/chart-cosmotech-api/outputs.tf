# # get "v5" from API version
# output "api_version_path" {
#   value = "v${substr("${helm_release.cosmotech_api.version}", 0, 1)}"
#   #   value = "v5"
# }