variable "tenant" {
  type = string
}

variable "image_registry" {
  type = string
}

variable "image_registry_auth_secret" {
  type = string
}

variable "chart_repository" {
  type = string
}

variable "chart_name" {
  type = string
}

variable "chart_tag" {
  type = string
}

variable "chart_release" {
  type = string
}

variable "s3_host" {
  type = string
}

variable "s3_port" {
  type = string
}

variable "s3_bucket" {
  type = string
}

variable "s3_secret" {
  type = string
}

variable "s3_secret_key_username" {
  type = string
}

variable "s3_secret_key_password" {
  type = string
}

# variable "postgresql_host" {
#   type = string
# }

# variable "postgresql_port" {
#   type = string
# }

# variable "postgresql_database" {
#   type = string
# }

# variable "postgresql_admin_username" {
#   type = string
# }

# variable "postgresql_admin_password" {
#   type = string
# }

# variable "postgresql_writer_username" {
#   type = string
# }

# variable "postgresql_writer_password" {
#   type = string
# }

# variable "postgresql_reader_username" {
#   type = string
# }

# variable "postgresql_reader_password" {
#   type = string
# }

variable "keycloak_client_id" {
  type = string
}

variable "keycloak_client_secret" {
  type = string
}

# variable "cosmotech_api_connect_timeout" {
#   default = "30s"
# }

# variable "cosmotech_api_query_timeout" {
#   default = "60s"
# }

# variable "cosmotech_api_buffer_size" {
#   default = "16K"
# }

# variable "cosmotech_api_max_file_size" {
#   default = "300m"
# }

variable "cluster_domain" {
  type = string
}


variable "postgresql_image_repository" {
  type = string
}

variable "postgresql_image_tag" {
  type = string
}

variable "use_external_postgresql" {
  type = bool
}

variable "external_postgresql_host" {
  type = string
}

variable "external_postgresql_port" {
  type = string
}

variable "external_postgresql_username" {
  type = string
}

variable "external_postgresql_password" {
  type = string
}
