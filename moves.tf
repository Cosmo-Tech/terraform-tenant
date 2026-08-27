## Since 0.1.0
moved {
  from = module.storage_azure
  to   = module.storage
}



## Since 2.0.0 (passwords used in PostgreSQL were all created in a same random_password resource)
moved {
  from = module.chart_postgresql.random_password.password[1]
  to   = module.postgresql_cnpg_cluster.random_password.postgres_password
}

moved {
  from = module.chart_postgresql.random_password.password[2]
  to   = module.chart_seaweedfs.random_password.seaweedfs_postgresql_password
}

moved {
  from = module.chart_postgresql.random_password.password[3]
  to   = module.chart_argo.random_password.argo_database_password
}

moved {
  from = module.chart_postgresql.random_password.password[4]
  to   = module.chart_cosmotech_api.random_password.api_admin_password
}

moved {
  from = module.chart_postgresql.random_password.password[5]
  to   = module.chart_cosmotech_api.random_password.api_writer_password
}

moved {
  from = module.chart_postgresql.random_password.password[6]
  to   = module.chart_cosmotech_api.random_password.api_reader_password
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
