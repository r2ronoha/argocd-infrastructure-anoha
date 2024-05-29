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
    vpc_id           = "mock"
  }
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v5.1.2"
}

inputs = {
  name         = "argocd-infra-${local.env_vars.locals.tags.environment}-${local.region_vars.locals.aws_region}-redis"
  description  = "Security group for argocd-infrastructure Redis"
  vpc_id       = "data.aws_ssm_parameters_by_path.ssm-read.outputs.vpc_id"
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
