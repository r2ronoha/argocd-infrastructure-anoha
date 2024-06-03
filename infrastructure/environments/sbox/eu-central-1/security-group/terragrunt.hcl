locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v5.1.2"
}

inputs = {
  name         = "argocd-infra-${local.env_vars.locals.tags.environment}-${local.region_vars.locals.aws_region}-redis"
  description  = "Security group for argocd-infrastructure Redis"
  vpc_id       = "vpc-009b4ffc6d22516c5" #this value can't be taken from SSM on sbox
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
