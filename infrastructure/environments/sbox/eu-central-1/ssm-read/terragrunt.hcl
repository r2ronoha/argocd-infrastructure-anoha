locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/modules//ssm-read"
}

inputs = {
  ssm_vpc_path = "/cloud/vpc/delta-${local.env_vars.locals.tags.environment}/attributes/vpc_id"
  ssm_sn_path  = "/cloud/vpc/eks/attributes/subnets/db_sn_ids"
}
