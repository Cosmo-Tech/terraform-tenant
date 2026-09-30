## Since 0.1.0
moved {
  from = module.storage_azure
  to   = module.storage
}

## Since 2.0.0 (the new "count" in the modules requires now to use the index [0])
moved {
  from = module.config_keycloak_realm
  to   = module.config_keycloak_realm[0]
}

moved {
  from = module.chart_seaweedfs
  to   = module.chart_seaweedfs[0]
}

moved {
  from = module.chart_redis
  to   = module.chart_redis[0]
}

moved {
  from = module.config_grafana_dashboard
  to   = module.config_grafana_dashboard[0]
}

moved {
  from = module.config_harbor_project
  to   = module.config_harbor_project[0]
}

moved {
  from = module.config_superset_oauth_provider
  to   = module.config_superset_oauth_provider[0]
}

## Since 2.0.0 (Renommage des modules ET ajout du paramètre "count")
moved {
  from = module.chart_cosmotech_api
  to   = module.chart_cosmotech_run_api[0]
}

moved {
  from = module.chart_argo
  to   = module.chart_argo_workflows[0]
}


## Since 2.0.0 (passwords used in PostgreSQL were all created in a same random_password resource)
moved {
  from = module.chart_postgresql.random_password.password[1]
  to   = module.postgresql_cnpg_cluster[0].random_password.postgres_password
}

moved {
  from = module.chart_postgresql.random_password.password[2]
  to   = module.chart_seaweedfs[0].random_password.seaweedfs_postgresql_password
}

moved {
  from = module.chart_postgresql.random_password.password[3]
  to   = module.chart_argo_workflows[0].random_password.argo_database_password
}

moved {
  from = module.chart_postgresql.random_password.password[4]
  to   = module.chart_cosmotech_run_api[0].random_password.api_admin_password
}

moved {
  from = module.chart_postgresql.random_password.password[5]
  to   = module.chart_cosmotech_run_api[0].random_password.api_writer_password
}

moved {
  from = module.chart_postgresql.random_password.password[6]
  to   = module.chart_cosmotech_run_api[0].random_password.api_reader_password
}


## Since 2.0.0 (passwords used in SeaweedFS were all created in a same random_password resource)
moved {
  from = module.chart_seaweedfs.random_password.password[0]
  to   = module.chart_seaweedfs.random_password.s3_argo_workflows_password
}

moved {
  from = module.chart_seaweedfs.random_password.password[1]
  to   = module.chart_seaweedfs.random_password.s3_cosmotech_api_password
}