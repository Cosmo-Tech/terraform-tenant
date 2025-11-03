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


# Get value of a variable declared in a given file from this pattern: variable = value
# Usage: get_var_value <file> <variable>
get_var_value() {
    local file=$1
    local variable=$2

    cat $file | grep '=' | grep -w $variable | sed 's|.*"\(.*\)".*|\1|' | head -n 1
}

tenant_name="$(get_var_value terraform-webapp/terraform.tfvars tenant)"
webapp_name="$(get_var_value terraform-webapp/terraform.tfvars webapp_name)"
state_file_name="tfstate-tenant-$tenant_name-webapp-$webapp_name"

# Clear old data
rm -rf terraform-webapp/.terraform*
rm -rf terraform-webapp/terraform.tfstate*

# Deploy
terraform -chdir=terraform-webapp init -upgrade -backend-config="key=$state_file_name" 
terraform -chdir=terraform-webapp plan -out .terraform.plan
terraform -chdir=terraform-webapp apply .terraform.plan


exit