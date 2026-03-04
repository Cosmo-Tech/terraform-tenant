#!/bin/sh

# Script to run terraform modules 
# Usage :
# - ./script.sh


# Stop script if missing dependency
required_commands="terraform"
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
cluster_region="$(get_var_value terraform.tfvars cluster_region)"
cluster_name="$(get_var_value terraform.tfvars cluster_name)"
state_file_name="tfstate-$cluster_name-tenant-$(get_var_value terraform.tfvars tenant)"


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
        terraform {
            backend \"azurerm\" {
                key                  = \"$state_file_name\"
                storage_account_name = \"cosmotechstates\"
                container_name       = \"cosmotechstates\"
                resource_group_name  = \"cosmotechstates\"
            }
        }

        provider \"azurerm\" {
            features {}
            subscription_id = var.azure_subscription_id
            tenant_id       = var.azure_entra_tenant_id
        }

        variable \"azure_subscription_id\" { type = string }
        variable \"azure_entra_tenant_id\" { type = string }

        data \"azurerm_kubernetes_cluster\" \"cluster\" {
          name                = \"$cluster_name\"
          resource_group_name = \"$cluster_name\"
        }

        module \"storage_azure\" {
          source = \"git::https://github.com/cosmo-tech/terraform-azure.git//terraform-cluster/modules/storage\"

          for_each = var.cloud_provider == \"azure\" ? local.persistences : {}

          namespace          = module.kube_namespace.tenant
          resource           = each.value.name
          size               = each.value.size
          resource_group     = data.azurerm_kubernetes_cluster.cluster.node_resource_group
          storage_class_name = local.storage_class_name
          region             = var.cluster_region
          cloud_provider     = var.cloud_provider
        }

    " > $backend_file ;;

  'aws')
    echo " \
        provider \"aws\" {
            region = var.region
        }
        terraform {
            backend \"s3\" {
                key    = \"$state_file_name\"
                bucket = \"cosmotech-states\"
                region = \"$cluster_region\"
            }
        }

      module \"storage_aws\" {
        source = \"git::https://github.com/cosmo-tech/terraform-aws.git//terraform-cluster/modules/storage\"

        for_each = var.cloud_provider == \"aws\" ? local.persistences : {}

        namespace          = module.kube_namespace.tenant
        resource           = each.value.name
        size               = each.value.size
        storage_class_name = local.storage_class_name
        region             = var.cluster_region
        cloud_provider     = var.cloud_provider
      }

    " > $backend_file ;;

  'gcp')
    state_storage_name='"cosmotech-states"'
    echo " \
        terraform {
          backend \"gcs\" {
            bucket = $state_storage_name
            prefix = "$state_file_name"
          }
        }

        provider \"google\" {
          project = var.project_id
          region  = var.cluster_region
        }

        variable \"project_id\" { type = string }

        data \"terraform_remote_state\" \"terraform_cluster\" {
          backend = \"gcs\"
          config = {
            bucket = $state_storage_name
            # prefix = \"\"
          }
        }

        data \"google_client_config\" \"current\" {}

        module \"storage_gcp\" {
          source = \"git::https://github.com/cosmo-tech/terraform-gcp.git//terraform-cluster/modules/storage\"

          for_each = var.cloud_provider == \"gcp\" ? local.persistences : {}

          namespace          = module.kube_namespace.tenant
          resource           = each.value.name
          size               = each.value.size
          storage_class_name = local.storage_class_name
          region             = var.cluster_region
          cloud_provider     = var.cloud_provider
        }

    " > $backend_file ;;

  'kob')
    state_url="$(get_var_value terraform.tfvars state_host)/$state_file_name"

    if [ -z $TF_HTTP_USERNAME ] || [ -z $TF_HTTP_PASSWORD ]; then
        echo "error: empty TF_HTTP_USERNAME or TF_HTTP_PASSWORD (required for backend authentication)"
        echo "  export TF_HTTP_USERNAME="
        echo "  export TF_HTTP_PASSWORD="
        exit
    else
        echo "found TF_HTTP_USERNAME & TF_HTTP_PASSWORD"
    fi

    export TF_CLI_ARGS="-lock=false"

    echo " \
      terraform {
        backend \"http\" {
          update_method = \"PUT\"
          lock_method   = \"POST\"
          unlock_method = \"DELETE\"
          skip_cert_verification = true

          address = \"$state_url\"
          lock_address = \"$state_url/lock\"
          unlock_address = \"$state_url/lock\"
        }
      }

      variable \"state_host\" { type = string }

      locals {
        cloud_identity = {}
        lb_annotations = {}
        lb_ip = \"\"
      }

      module \"storage_kob\" {
        # source = \"git::https://github.com/cosmo-tech/terraform-onprem.git//terraform-cluster/modules/storage\"
        source = \"git::https://github.com/cosmo-tech/terraform-onprem//terraform-cluster/modules/storage?ref=standardization\"

        for_each = var.cloud_provider == \"kob\" ? local.persistences : {}

        namespace          = module.kube_namespace.tenant
        resource           = \"\${var.cluster_name}-\${each.key}\"
        size               = each.value.size
        storage_class_name = local.storage_class_name
        region             = var.cluster_region
        cloud_provider     = var.cloud_provider
      }

    " > "$backend_file";;
  *)
    echo "error: unknown or empty \e[91mcloud_provider\e[0m from terraform.tfvars"
    exit
    ;;
esac


# Deploy
terraform fmt $backend_file
terraform init -upgrade -reconfigure
terraform plan -out .terraform.plan
# terraform apply .terraform.plan


exit
