locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))
}

include {
  path = find_in_parent_folders()
}

dependency "ssm-read" {
  config_path                             = "../ssm-read"
  mock_outputs_allowed_terraform_commands = ["validate-inputs", "validate", "plan", "output"]
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    vpc_id   = "mock"
    db_sn_id = ["mock"]
  }
}

dependency "security_groups" {
  config_path                             = "../security-group"
  mock_outputs_allowed_terraform_commands = ["validate-inputs", "validate", "plan", "output"]
  mock_outputs = {
    security_group_id = "mock"
  }
}

terraform {
  source = "github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=1.2.2"
}

inputs = {
  name                          = "argocd-infra-${local.env_vars.locals.tags.environment}-redis"
  vpc_id                        = dependency.ssm-read.outputs.vpc_id
  subnets                       = dependency.ssm-read.outputs.db_sn_id
  instance_type                 = "cache.t2.small"
  apply_immediately             = true
  automatic_failover_enabled    = false
  engine_version                = "7.1"
  create_security_group         = false
  description                   = "Redis for ArgoCD"
  family                        = "redis7"
  at_rest_encryption_enabled    = false
  transit_encryption_enabled    = false
  associated_security_group_ids = [dependency.security_groups.outputs.security_group_id]
}
