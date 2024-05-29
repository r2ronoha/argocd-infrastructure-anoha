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
    vpc_id          = "mock"
    public_subnets  = ["mock"]
    private_subnets = ["mock"]
  }
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v5.1.2"
}

inputs = {
  name         = "argocd-infra-${local.env_vars.locals.tags.environment}-${local.region_vars.locals.aws_region}-redis"
  description  = "Security group for argocd-infrastructure Redis"
  vpc_id       = dependency.base_remote_state.outputs.vpc_id
  egress_rules = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = "6379"
      to_port     = "6379"
      protocol    = "tcp"
      cidr_blocks = "10.0.0.0/8"
    }
  ]
}
