locals {
  common_repositories = read_terragrunt_config(find_in_parent_folders("../../_envcommon/repositories.hcl"))
  env_vars            = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars         = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))

  formatted_repositories_admin = [
    for repo in local.common_repositories.locals.repositories :
    format("repo:%s:${local.env_vars.locals.repositories_suffix_admin}", repo)
  ]

  formatted_repositories_tf_plan = [
    for repo in local.common_repositories.locals.repositories :
    format("repo:%s:${local.env_vars.locals.repositories_suffix_tf_plan}", repo)
  ]
}



include {
  path = find_in_parent_folders()
}


dependency "policy" {
  config_path = "../policy"

  mock_outputs_allowed_terraform_commands = ["validate-inputs", "validate", "plan", "output"]
  mock_outputs = {
    wrapper = {
      tf_plan = {
        arn = "arn:aws:iam::aws:policy/mock" # Mocking policy arn
      }
    }
  }
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//wrappers/iam-assumable-role-with-oidc?ref=v5.39.0"
}

inputs = {
  defaults = {
    create_role = true

    provider_url = "token.actions.githubusercontent.com/jamf"
  }

  items = {
    argocd_secret = {
      role_name                    = "argocd_secret-${local.region_vars.locals.aws_region}-${local.env_vars.locals.tags.environment}"
      role_description             = "Role for argocd-infrastructure to access external secrets"
      oidc_subjects_with_wildcards = local.formatted_repositories_admin

      # Cloud Wan resources require Admin access
      role_policy_arns = ["${dependency.policy.outputs.wrapper.argocd_secret.arn}"]
    }
  }
}