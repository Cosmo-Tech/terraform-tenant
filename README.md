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

## Developpers
* modules
    * **terraform-tenant**
        * install Cosmo Tech API and all its dependencies in a dedicated namespace
    * **terraform-webapp**
        * install Cosmo Tech webapp in the tenant created from terraform-tenant

<br>
<br>
<br>

Made with :heart: by Cosmo Tech DevOps team