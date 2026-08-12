terraform {
  required_version = "~> 1.13"

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
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.27.0"
    }
  }
}


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

provider "postgresql" {
  host             = local.external_postgres_host
  port             = var.external_postgres_port
  username         = var.external_postgres_admin_username
  password         = var.external_postgres_admin_password
  sslmode          = var.external_postgres_sslmode
  superuser        = var.external_postgres_superuser
  connect_timeout  = 15
}