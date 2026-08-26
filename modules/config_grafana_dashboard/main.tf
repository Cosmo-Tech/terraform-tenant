terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
}


data "kubernetes_secret" "redis" {
  metadata {
    namespace = var.tenant
    name      = "redis"
  }
}

resource "grafana_data_source" "redis-datasource" {
  name = "${var.tenant}-redis"
  type = "redis-datasource"

  url = "redis://redis-master.${var.tenant}.svc.cluster.local:6379"

  basic_auth_enabled  = true
  basic_auth_username = "default"
  secure_json_data_encoded = jsonencode({
    password = data.kubernetes_secret.redis.data["redis-password"]
  })
}


data "kubernetes_secret" "postgresql" {
  metadata {
    namespace = var.tenant
    name      = "postgresql-config"
  }
}

resource "grafana_data_source" "postgresql-datasource" {
  name = "${var.tenant}-postgresql"
  type = "grafana-postgresql-datasource"

  url                = "postgresql.${var.tenant}.svc.cluster.local:5432"
  basic_auth_enabled = true
  username           = "postgres"
  secure_json_data_encoded = jsonencode({
    password = data.kubernetes_secret.postgresql.data["password"]
  })

  json_data_encoded = jsonencode({
    sslmode = "disable"
  })

  database_name = "argo"
}


resource "grafana_folder" "folder" {
  title = var.tenant
}

resource "grafana_dashboard" "redis" {
  folder = grafana_folder.folder.id
  config_json = templatefile("${path.module}/dashboards/redis.json",
    {
      "title" = "Redis_${var.tenant}", "DATASOURCE_ID" = split(":", grafana_data_source.redis-datasource.id)[1]
    }
  )
}

resource "grafana_dashboard" "cosmotech_licensing" {
  folder = grafana_folder.folder.id
  config_json = templatefile(
    "${path.module}/dashboards/cosmotech_licensing.json",
    {
      "DASHBOARD_TITLE"          = "Cosmotech_licencing_${var.tenant}",
      "REDIS_DATASOURCE_ID"      = split(":", grafana_data_source.redis-datasource.id)[1],
      "POSTGRESQL_DATASOURCE_ID" = split(":", grafana_data_source.postgresql-datasource.id)[1]
    }
  )
}
