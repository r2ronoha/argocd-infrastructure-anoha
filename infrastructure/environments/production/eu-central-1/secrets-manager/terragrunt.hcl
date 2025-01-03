locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))

  s3_bucket_prefix = "delta-tfstate"
  dynamodb_prefix  = "tfstate-lock"
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-secrets-manager//wrappers?ref=v1.1.2"
}

inputs = {
  defaults = {
    create                  = true
    recovery_window_in_days = "30"
    create_policy           = true
    block_public_policy     = true
    policy_statements = {
      read = {
        sid = "AllowAccountRead"
        principals = [{
          type        = "AWS"
          identifiers = ["arn:aws:iam::${local.env_vars.locals.account_id}:root"]
        }]
        actions   = ["secretsmanager:GetSecretValue"]
        resources = ["*"]
      }
    }
  }
  items = {
    wandera_git = {
      name        = "/argocd/infrastructure/wandera-git"
      description = "AWS Secret Manager entry for GitHub Wandera Org. Credentials"

      # Version
      ignore_secret_changes = true
      secret_string = jsonencode({
        username = "wandera-viewer",
        password = "Initial",
        url      = "https://github.com/wandera"
      })
    }

    jamf_git = {
      name        = "/argocd/infrastructure/jamf-git"
      description = "AWS Secret Manager entry for GitHub Jamf App"

      # Version
      ignore_secret_changes = true
      secret_string = jsonencode({
        githubAppPrivateKey     = "github-app",
        githubAppID             = "Initial",
        githubAppInstallationID = "Initial"
      })
    }
  }
}
