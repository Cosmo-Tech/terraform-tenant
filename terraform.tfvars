# ## VARIABLES EXAMPLE FOR AZURE
# cloud_provider        = "azure"
# cluster_region        = "westeurope"
# cluster_name          = "aks-dev-devops"
# domain_zone           = "azure.platform.cosmotech.com"
# tenant                = "test0"
# azure_subscription_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"
# azure_entra_tenant_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"


# ## VARIABLES EXAMPLE FOR AWS
# cloud_provider     = "aws"
# cluster_region     = "eu-west-3"
# cluster_name       = "eks-dev-devops"
# domain_zone        = "aws.platform.cosmotech.com"
# tenant             = "test0"


# ## VARIABLES EXAMPLE FOR GCP
# cloud_provider     = "gcp"
# cluster_name       = "gke-dev-devops"
# domain_zone        = "gcp.platform.cosmotech.com"
# tenant             = "test0"


# ## VARIABLES EXAMPLE FOR KOB (= On-Premise)
# cloud_provider = "kob"
# cluster_name   = "kob-dev-devops"
# domain_zone    = "onpremise.platform.cosmotech.com"
# tenant         = "test0"
# state_host     = "https://cosmotechstates.onpremise.platform.cosmotech.com"


# ## GLOBAL VARIABLES EXAMPLES
# tenant_type = "run"
# tenant_type = "modeling"
# tenant_type = "asset"
# tenant_type = "asset-investment-planning"

# cosmotech_business_webapp_name = "business"
# powerbi_app_deploy             = false # Azure only
# cosmotech_business_webapp_image_repository_server     = "repo_url"  # Used to costomize the image repository for the web app server
# cosmotech_business_webapp_image_tag_server            = "tag_name"  # Used to costomize the image tag for the web app server

# cosmotech_business_webapp_image_repository_functions  = "repo_url"  # Used to costomize the image repository for the web app functions
# cosmotech_business_webapp_image_tag_functions         = "tag_name"  # Used to costomize the image tag for the web app functions

# use_external_postgresql                     = false
# external_postgresql_host                    = "changeme"
# external_postgresql_port                    = "changeme"
# ## Do not store credentials in current file
# export TF_VAR_external_postgresql_username  = "changeme"
# export TF_VAR_external_postgresql_password  = "changeme"
