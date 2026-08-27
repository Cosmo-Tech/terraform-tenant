config {
  call_module_type = "none" # cannot select another type due to target.tf which is created from _run-terraform.sh
}

rule "terraform_unused_declarations" { enabled = false }
rule "terraform_standard_module_structure" { enabled = false }
rule "terraform_required_providers" { enabled = false }
rule "terraform_required_version" { enabled = false }

rule "terraform_deprecated_interpolation" { enabled = true }