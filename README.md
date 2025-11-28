![Static Badge](https://img.shields.io/badge/Cosmo%20Tech-%23FFB039?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/tenant-%23f8f8f7?style=for-the-badge)


# Cosmo Tech tenant

## Requirements
* working Kubernetes cluster (with admin access)
* Linux (Debian/Ubuntu) workstation with:
    * [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    * [jq](https://jqlang.org/)
* if Azure: [azure-cli](https://github.com/Azure/azure-cli) installed and ready to use
* if AWS: [aws-cli](https://github.com/aws/aws-cli) installed and ready to use

## How to
* clone & open the repository
    ```
    git clone https://github.com/Cosmo-Tech/terraform-tenant.git --branch <tag>
    cd terraform-tenant
    ```
* deploy
    * fill `terraform-cluster/terraform.tfvars` variables according to your needs
    * run pre-configured script
        ```
        ./_run-terraform.sh
        ```
    * Azure
        * will ask for the access key of the Azure Storage of "cosmotechstates"
            * go to Azure > Azure Storage > "cosmotechstates" > Access keys
            * copy/paste "Key" from "key1" or "key2" in the terraform input
    * AWS
        * to fill
    * GCP
        * to fill

## Known errors
* Error: Provider configuration not present
    > The tenant has been deleted or exists in an other cluster, but the state file still exists. Chose another tenant name or delete the state file if tenant doesn't exist anymore.
* Error: [POST /datasources][409] addDataSourceConflict {"message":"data source with the same name already exists"} [..] with module.config_grafana_dashboard.grafana_data_source.redis-datasource
    > The state file could not be found (it has probably been deleted, but the deployed resources remains)
    > Go to https://<cluster_url>/monitoring (credentials are stored on Kubernetes secret monitoring/kube-prometheus-stack-grafana) -> Connections -> Data sources -> Delete both tenant-<name>-postgresql and tenant-<name>-redis
* Error: failed to create folder: [POST /folders][409] createFolderConflict {"message":"a folder with the same name already exists in the current location"} [..] with module.config_grafana_dashboard.grafana_folder.folder
    > The state file could not be found (it has probably been deleted, but the deployed resources remains)
    > Go to https://<cluster_url>/monitoring (credentials are stored on Kubernetes secret monitoring/kube-prometheus-stack-grafana) -> Dashboards -> Delete tenant-<name>
* Error: error sending POST request to /keycloak//admin/realms: 409 Conflict. Response body: {"errorMessage":"Conflict detected. See logs for details"} [..] with with module.config_keycloak_realm.keycloak_realm.realm
    > The state file could not be found (it has probably been deleted, but the deployed resources remains)
    > Go to https://<cluster_url>/keycloak (credentials are stored on Kubernetes secret keycloak/keycloak-config) -> Select the realm "tenant-<name>" -> Realm settings > Action > Delete

## Developpers
* modules
    * **terraform-tenant**
        * *install Cosmo Tech API and all its dependencies in a dedicated namespace*
        * *chart_argo* = install Argo Workflows
        * *chart_cosmotech_api* = install Cosmo Tech API
        * *chart_postgresql* = install PostgreSQL (and configure it for Cosmo Tech API, SeaweedFS & Argo Workflows)
        * *chart_redis* = install Redis
        * *chart_seaweedfs* = install SeaweedFS
        * *config_grafana_dashboard* = create tenant configuration on existing Grafana instance
        * *config_keycloak_realm* = create tenant configuration on existing Keycloak instance
        * *kube_namespace* = create tenant namespace
        * *storage* = **[temporary]** dynamically create persistence storage for charts requiring it
* Terraform **state**
    * The state is stored beside the cluster Terraform state, in the current cloud s3/blob storage service (generally called "cosmotech-states" or "cosmotechstates", depending on what the cloud provider allows in naming convention)
* File **backend.tf**
    * dynamically created at each run of _run-terraform.sh
    * permit to have multi-cloud compatibility with Terraform
    * it instanciate the needed Terraform providers based on the variable "cloud_provider" from terraform.tfvars
    * this file is a workaround to avoid having unwanted variables related to cloud providers not targetted in current deployment


<br>
<br>
<br>

Made with :heart: by Cosmo Tech DevOps team