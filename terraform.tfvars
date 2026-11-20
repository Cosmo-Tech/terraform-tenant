# ## VARIABLES EXAMPLE FOR AZURE
cloud_provider        = "azure"
cluster_region        = "francecentral"
cluster_name          = "aks-dev-joy"
domain_zone           = "azure.platform.cosmotech.com"
tenant                = "gateway"
azure_subscription_id = "a24b131f-bd0b-42e8-872a-bded9b91ab74"
azure_entra_tenant_id = "e413b834-8be8-4822-a370-be619545cb49"


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
tenant_type = "run"
# tenant_type = "modeling"
# tenant_type = "asset"
# tenant_type = "asset-investment-planning"

# use_external_postgresql = false
# external_postgresql_host = "changeme"
# external_postgresql_port = "changeme"
# ## Do not store credentials in current file
# export TF_VAR_external_postgresql_username="changeme"
# export TF_VAR_external_postgresql_password="changeme"
