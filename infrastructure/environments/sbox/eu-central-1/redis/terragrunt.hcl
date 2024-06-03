locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))
}

include {
  path = find_in_parent_folders()
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
  name                          = "argocd-infra-${local.env_vars.locals.tags.environment}-${local.region_vars.locals.aws_region}-redis"
  vpc_id                        = "vpc-009b4ffc6d22516c5" #this value can't be taken from SSM on sbox
  subnets                       = ["subnet-0272e8b5672c40318", "subnet-0b30205ac830bf36d", "subnet-06629ff459d378c94"]
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
