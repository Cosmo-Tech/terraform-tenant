output "superset_oauth_providers" {
  value = kubernetes_config_map.superset_oauth_providers.data
}

