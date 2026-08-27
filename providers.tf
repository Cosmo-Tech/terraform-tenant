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
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.4.1"
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


# PostgreSQL
provider "postgresql" {
  host            = var.external_postgresql_host
  port            = tonumber(var.external_postgresql_port)
  username        = var.external_postgresql_username
  password        = var.external_postgresql_password
  sslmode         = "require"
  superuser = false
  connect_timeout = 15
}
