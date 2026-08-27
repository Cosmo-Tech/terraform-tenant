config {
  call_module_type = "all"
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_deprecated_syntax" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}