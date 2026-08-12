# ## VARIABLES EXAMPLE FOR AZURE
cloud_provider        = "azure"
cluster_region        = "westeurope"
cluster_name          = "aks-dev-devops"
domain_zone           = "azure.platform.cosmotech.com"
tenant                = "test0"
azure_subscription_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"
azure_entra_tenant_id = "xxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx"


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
# cluster_name   = "kubernetes"
# domain_zone    = "onpremise.platform.cosmotech.com"
# tenant         = "test0"
# state_host     = "https://cosmotechstates.onpremise.platform.cosmotech.com"

# ## VARIABLES EXAMPLE FOR EXTERNAL POSTGRESQL
# ## (e.g. Azure PostgreSQL Flexible Server)
#
# ## The PostgreSQL server itself is expected to be provisioned by terraform-extra.
# ## Only the connection details are required here so Terraform can provision
# ## the tenant roles and databases.
#
# ## SECURITY NOTE:
# ## Do NOT store the PostgreSQL admin password in this file or commit it to Git.
# ## Provide it through the TF_VAR_external_postgres_admin_password environment
# ## variable instead.
#
# ## Example:
# ## export TF_VAR_external_postgres_admin_password='<password>'
use_external_postgres            = false
external_postgres_admin_username = "psqladmintest"