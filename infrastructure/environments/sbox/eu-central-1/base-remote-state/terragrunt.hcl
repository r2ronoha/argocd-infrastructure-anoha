locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))
  base_bucket = "delta-tfstate-${local.env_vars.locals.tags.environment}-${local.region_vars.locals.aws_region}"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/modules//base-remote-state"
}

inputs = {
  bucket = "${local.base_bucket}"
  key    = "terragrunt/tf-base-buildservices/environments/${local.env_vars.locals.tags.environment}/${local.region_vars.locals.aws_region}/vpc/terraform.tfstate"
  region = "${local.region_vars.locals.aws_region}"
}
