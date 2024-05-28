locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))
}

include {
  path = find_in_parent_folders()
}

dependency "base_remote_state" {
  config_path                             = "../base-remote-state"
  mock_outputs_allowed_terraform_commands = ["validate-inputs", "validate", "plan", "output"]
  mock_outputs = {
    vpc_id           = "mock"
    database_subnets = ["mock"]
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
  vpc_id                        = dependency.base_remote_state.outputs.vpc_id
  subnets                       = dependency.base_remote_state.outputs.database_subnets
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
