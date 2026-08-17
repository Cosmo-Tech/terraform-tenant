locals {
  # Define only the required modules for each tenant type. A module in this list means it will be deployed, do not write a module that is not required.
  tenant_recipes = {
    standard = [
      "chart_cosmotech_api",
      "chart_argo",
      "chart_postgresql",
      "chart_redis",
      "chart_seaweedfs",
      "config_grafana_dashboard",
      "config_harbor_project",
      "config_keycloak_realm",
      "config_superset_oauth",
    ]

    modeling = [
      "chart_cosmotech_modeling_api",
      "chart_argo",
      "chart_seaweedfs",
      "chart_postgresql", # Required for Argo Workflows & SeaweedFS
    ]

    asset = [
      # "todo",
    ]

    asset_portfolio = [
      "chart_cosmotech_portfolio_api",
      "chart_cosmotech_portfolio_webapp",
      "chart_postgresql",
      "config_keycloak_realm",
    ]
  }

  # Get the list of the required modules
  tenant_recipe_modules = local.tenant_recipes[var.tenant_type]
}