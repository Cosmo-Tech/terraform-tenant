output "superset_oauth_providers" {
  value = kubectl_manifest.superset_oauth_providers.yaml_body
}

