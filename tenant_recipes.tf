locals {
  # Define only the required modules for each tenant type. A module in this list means it will be deployed, do not write a module that is not required.
  tenant_recipes = {
    run = [
      "chart_cosmotech_run_api",
      "chart_cosmotech_gateway",
      "chart_cosmotech_business_webapp",
      "config_powerbi_app", # Only for run business webapp (still requires azure + powerbi_app_deploy = true)
      "chart_argo_workflows",
      "chart_redis",
      "chart_seaweedfs",
      "postgresql_cnpg_cluster",
      "config_grafana_dashboard",
      "config_harbor_project",
      "config_keycloak_realm",
      "config_superset_oauth",
    ]

    modeling = [
      "chart_cosmotech_run_api",
      "chart_cosmotech_gateway",
      "chart_cosmotech_modeling_api",
      "chart_argo_workflows",
      "chart_redis",
      "chart_seaweedfs",
      "postgresql_cnpg_cluster",
      "config_grafana_dashboard",
      "config_harbor_project",
      "config_keycloak_realm",
      "config_superset_oauth",
    ]

    asset = [
      "chart_cosmotech_asset_data_layer",
      "chart_cosmotech_run_api",
      "chart_cosmotech_gateway",
      "chart_cosmotech_business_webapp",
      "chart_argo_workflows",
      "chart_redis",
      "chart_seaweedfs",
      "postgresql_cnpg_cluster",
      "config_grafana_dashboard",
      "config_harbor_project",
      "config_keycloak_realm",
      "config_superset_oauth",
    ]

    asset-investment-planning = [
      "chart_cosmotech_asset_investment_planning_api",
      "chart_cosmotech_asset_investment_planning_webapp",
      "postgresql_cnpg_cluster",
      "config_keycloak_realm",
    ]
  }

  # Get the list of the required modules
  tenant_recipe_modules = local.tenant_recipes[var.tenant_type]

  business_webapp_name                     = "webapp-${var.cosmotech_business_webapp_name}"
  business_webapp_asset_data_layer_enabled = contains(local.tenant_recipe_modules, "chart_cosmotech_asset_data_layer")
}