![Static Badge](https://img.shields.io/badge/Cosmo%20Tech-%23FFB039?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/tenant-%23f8f8f7?style=for-the-badge)


# Cosmo Tech tenant
*install Cosmo Tech API and all its dependencies in a dedicated namespace*

## Requirements
* working Kubernetes cluster deployed from Cosmo Tech terraform-provider (like terraform-azure for example)
* [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    > If using Windows, Terraform must be accessible from PATH
* situational
    * Azure: [azure-cli](https://github.com/Azure/azure-cli)
    * AWS: [aws-cli](https://github.com/aws/aws-cli)

## How to
* clone & open the repository
    ```
    git clone https://github.com/Cosmo-Tech/terraform-tenant.git --branch <tag>
    cd terraform-tenant
    ```
* deploy
    * fill `terraform.tfvars` variables according to your needs
    * run pre-configured script
        * plan
            > get an execution plan to preview the changes without applying
            * Linux
                ```
                ./_run-terraform.sh
                ```
            * Windows
                ```
                ./_run-terraform.ps1
                ```
        * apply
            > executes the operations proposed in the plan
            * Linux
                ```
                ./_run-terraform.sh --apply
                ```
            * Windows
                ```
                ./_run-terraform.ps1 --apply
                ```

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
* Error: error connecting to PostgreSQL server xxxxxxxx.postgres.database.azure.com (scheme: postgres): dial tcp xxx.xxx.xxx.xxx:5432: i/o timeout
    > Make sure the ip address of you machine is adequately whitelisted in the PostgreSQL server firewall rules (tips: VPN)

## Developpers
* Terraform **state**
    * The state is stored beside the cluster Terraform state, in the current cloud s3/blob storage service (generally called `csmstates<id>` or `cosmotech-states`, depending on what the cloud provider allows in naming convention)
* Scripts **_run-terraform.***
    * Automatically detect hosting target (cloud provider name, on-premise...), and adapt the Terraform module to work with it
    * Terraform modules can work without the scripts, but will require some additional manual steps.
* File **target.tf**
    * Allow to have multi-cloud compatibility with Terraform
    * This file is dynamically created at each run of `_run-terraform`
    * It instanciates the needed Terraform configuration based on the variable `cloud_provider` from terraform.tfvars
        > `$TEMPLATE_` variables in files stored in `targets/` are automatically replaced with values from `terraform.tfvars`
    * This file is a workaround to avoid having unwanted variables related to cloud providers not targetted in current deployment
* File **variables_defaults**
    * contains all the defaults configurations of the module
    * all artefacts versions are tagged in this file
    * everything is this file can be customized from TF_VAR_variable, CLI arguments or terraform.tfvars

<br>
<br>
<br>

Made with :heart: by Cosmo Tech DevOps team