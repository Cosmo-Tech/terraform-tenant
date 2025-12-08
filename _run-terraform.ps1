

# Script to run terraform modules
# Usage :
# - ./script.ps1


# Stop script if missing dependency
$required_command = 'terraform'
foreach ($command in $required_command) {
    if (!(Get-Command -errorAction SilentlyContinue -Name $command)) {
        echo "error: required command not found in the PATH: $command"
        exit
    }
}


# Get value of a variable declared in a given file from this pattern: variable = "value"
# Usage: get_var_value <file> <variable>
function get_var_value {
    param($File, $Variable)

    $value = (cat $File | select-string $Variable | select-string '=' | select-string -Pattern '#.*' -NotMatch | select -first 1)
    $value -replace '.*=.*\"(.*)\".*','$1'
}
$cloud_provider = (get_var_value 'terraform.tfvars' 'cloud_provider')
$cluster_region = (get_var_value 'terraform.tfvars' 'cluster_region')
$cluster_name = (get_var_value 'terraform.tfvars' 'cluster_name')
$state_file_name = "tfstate-shared-$cluster_name"


# Clear old data
rm -Recurse -Confirm:$false .terraform*
rm -Recurse -Confirm:$false terraform.tfstate*


# The trick here is to write configuration in a dynamic file created at the begin of the
# execution, containing the config that the concerned provider is waiting for Terraform backend.
# Then, Terraform will automatically detects it from its .tf extension.
$backend_file = 'backend.tf'
switch ($cloud_provider) {
    "azure" {
        $state_storage_name = 'cosmotechstates'
        echo "
        terraform {
            backend ""azurerm"" {
                key                  = ""$state_file_name""
                storage_account_name = ""cosmotechstates""
                container_name       = ""cosmotechstates""
                resource_group_name  = ""cosmotechstates""
            }
        }

        provider ""azurerm"" {
            features {}
            subscription_id = var.azure_subscription_id
            tenant_id       = var.azure_entra_tenant_id
        }

        variable ""azure_subscription_id"" { type = string }
        variable ""azure_entra_tenant_id"" { type = string }
        " > $backend_file
    }

    "aws" {
        $state_storage_name = 'cosmotech-states'
        echo "
            provider ""aws"" {
                region = var.region
            }
            terraform {
                backend ""s3"" {
                    key    = ""$state_file_name""
                    bucket = ""cosmotech-states""
                    region = ""$cluster_region""
                }
            }
        " > $backend_file
    }

    "gcp" {
        $state_storage_name = 'cosmotech-states'
        echo "
            terraform {
                backend ""gcs"" {
                    bucket = $state_storage_name
                    prefix = ""$state_file_name""
                }
            }

            provider ""google"" {
                project = var.project_id
                region  = var.cluster_region
            }

            variable ""project_id"" { type = string }

            data ""terraform_remote_state"" ""terraform_cluster"" {
                backend = ""gcs""
                config = {
                    bucket = $state_storage_name
                }
            }

            data ""google_client_config"" ""current"" {}
        " > $backend_file
    }
}
# Convert backend_file to UNIX format, otherwise Terraform will not be able to read it
((Get-Content $backend_file) -join "`n") + "`n" | Set-Content -NoNewline $backend_file


# Dynamically replace the storage module block to call the right provider
$main_file = 'main.tf'
(Get-Content $main_file) -replace '(.*/modules/storage/).*"(.*)', "`$1$cloud_provider`"$2" | Set-Content $main_file
((Get-Content $main_file) -join "`n") + "`n" | Set-Content -NoNewline $main_file # Convert to UNIX format


# Deploy
terraform fmt $backend_file
terraform init -lock=false -upgrade -reconfigure
terraform plan -lock=false -out .terraform.plan
# terraform apply -lock=false .terraform.plan


echo ''
exit 0