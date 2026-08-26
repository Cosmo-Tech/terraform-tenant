terraform {
  required_version = ">= 1.15.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.14.0"
    }
    harbor = {
      source  = "goharbor/harbor"
      version = "~> 3.11.6"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.7.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.27.0"
    }
  }
}

## Global
provider "kubernetes" {
  config_path            = "~/.kube/config"
  config_context_cluster = var.cluster_name
}

provider "helm" {
  kubernetes = {
    config_path            = "~/.kube/config"
    config_context_cluster = var.cluster_name
  }
}



## Keycloak
data "kubernetes_secret" "keycloak" {
  metadata {
    namespace = "keycloak"
    name      = "keycloak-config"
  }
}

provider "keycloak" {
  url       = "https://${local.cluster_domain}/keycloak"
  client_id = "admin-cli"
  username  = data.kubernetes_secret.keycloak.data["keycloak_admin_user"]
  password  = data.kubernetes_secret.keycloak.data["keycloak_admin_password"]
}



## Grafana
data "kubernetes_secret" "grafana" {
  metadata {
    namespace = "monitoring"
    name      = "kube-prometheus-stack-grafana"
  }
}

provider "grafana" {
  url  = "https://${local.cluster_domain}/monitoring"
  auth = "admin:${data.kubernetes_secret.grafana.data["admin-password"]}"
}



## Harbor
provider "harbor" {
  url      = "http://${local.cluster_domain}"
  username = "admin"
  password = data.kubernetes_secret.harbor.data["harbor_admin_password"]
}

data "kubernetes_secret" "harbor" {
  metadata {
    namespace = "harbor"
    name      = "harbor-config"
  }
}



## PostgreSQL
provider "postgresql" {
  host             = local.external_postgres_host
  port             = var.external_postgres_port
  username         = var.external_postgres_admin_username
  password         = var.external_postgres_admin_password
  sslmode          = var.external_postgres_sslmode
  superuser        = var.external_postgres_superuser
  connect_timeout  = 15
}
