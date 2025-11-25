#!/bin/sh

# Script to run terraform modules 
# Usage :
# - ./script.sh


# Stop script if missing dependency
required_commands="terraform aws jq"
for command in $required_commands; do
	if [ -z "$(command -v $command)" ]; then
		echo "error: required command not found: \e[91m$command\e[97m"
        exit
	fi
done


# Get value of a variable declared in a given file from this pattern: variable = "value"
# Usage: get_var_value <file> <variable>
get_var_value() {
    local file=$1
    local variable=$2

    cat $file | grep '=' | grep -w $variable | sed '/.*#.*/d' | sed 's|.*=.*"\(.*\)".*|\1|' | head -n 1
}
cloud_provider="$(get_var_value terraform.tfvars cloud_provider)"
region="$(get_var_value terraform.tfvars region)"
state_file_name="tfstate-tenant-$(get_var_value terraform.tfvars tenant)"


# Clear old data
rm -rf .terraform*
rm -rf terraform.tfstate*


# The trick here is to write configuration in a dynamic file created at the begin of the
# execution, containing the config that the concerned provider is waiting for Terraform backend.
# Then, Terraform will automatically detects it from its .tf extension.
backend_file="backend.tf"
case "$(echo $cloud_provider)" in
  'azure')
    echo " \
        # data "azurerm_subscription" "current" {}
        provider "azurerm" {
            features {}
            # subscription_id = data.azurerm_subscription.current.subscription_id
            # tenant_id       = data.azurerm_subscription.current.tenant_id
            subscription_id = var.azure_subscription_id
            tenant_id       = var.azure_entra_tenant_id
        }    
        terraform {
            backend \"azurerm\" {
                key=\"$state_file_name\"
                storage_account_name=\"cosmotechstates\"
                container_name=\"cosmotechstates\"
                resource_group_name=\"cosmotechstates\"
            }
        }
        variable "azure_subscription_id" { type = string }
        variable "azure_entra_tenant_id" { type = string }
        # variable "azure_resource_group" { type = string }
    " > $backend_file ;;

  'aws')
    echo " \
        provider "aws" {
            region = var.region
        }
        terraform {
            backend \"s3\" {
                key=\"$state_file_name\"
                bucket=\"cosmotech-states\"
                region=\"$region\"
            }
        }
    " > $backend_file ;;

  'gcp')
    echo "NOT IMPLEMENTED YET" && exit
    ;;

  *)
    echo "error: unknown or empty \e[91mcloud_provider\e[0m from terraform.tfvars"
    exit
    ;;
esac


# Dynamically replace the storage module block to call the right provider
sed -i "s|\(.*/modules/kube-storage/\).*\"\(.*\)|\1$cloud_provider\"\2|" main.tf
# sed -i "s|\(.*for_each.*var.cloud_provider.*\)\".*\"\(.*\)|\1\"$cloud_provider\"\2|" main.tf


# Deploy
terraform fmt $backend_file
terraform init -upgrade -reconfigure
terraform plan -out .terraform.plan
terraform apply .terraform.plan



# terraform plan -var-file="terraform.tfvars"
# terraform apply -var-file="terraform.tfvars" -auto-approve
# terraform destroy -var-file="terraform.tfvars"

exit