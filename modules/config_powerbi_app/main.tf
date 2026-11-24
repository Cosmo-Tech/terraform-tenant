terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

locals {
  client_name = "${var.webapp_name}-powerbi-client"
}

# Application powerbi
resource "azuread_application" "powerbi" {
  display_name     = "${var.cluster_name}-${var.namespace}-${local.client_name}"
  sign_in_audience = "AzureADMyOrg"
}

resource "azuread_service_principal" "powerbi" {
  client_id                    = azuread_application.powerbi.client_id
  app_role_assignment_required = false
  depends_on                   = [azuread_application.powerbi]
}

resource "azuread_application_password" "powerbi_password" {
  display_name   = "powerbi_secret"
  application_id = azuread_application.powerbi.id
  depends_on     = [azuread_service_principal.powerbi]
}

# Existing "PowerBI" Azure AD group
data "azuread_group" "powerbi" {
  display_name     = "PowerBI"
  security_enabled = true
}

resource "azuread_group_member" "powerbi" {
  group_object_id  = data.azuread_group.powerbi.object_id
  member_object_id = azuread_service_principal.powerbi.object_id
}

resource "kubernetes_secret" "powerbi" {
  metadata {
    name      = local.client_name
    namespace = var.namespace
  }
  data = {
    "client_id"     = azuread_application.powerbi.client_id
    "client_secret" = azuread_application_password.powerbi_password.value
  }
}