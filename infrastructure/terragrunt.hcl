terraform_version_constraint  = "1.7.0"
terragrunt_version_constraint = "0.57.13"

locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("../../_envcommon/tags.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))

  ## WARNING: GITHUB REPOSITORY NAME HARDCODED HERE!!!! ##
  s3_bucket_key_path = "terragrunt/argocd-infrastructure/${path_relative_to_include()}/terraform.tfstate"

  s3_bucket_prefix = "delta-tfstate"
  dynamodb_prefix  = "tfstate-lock"

  aws_provider_version = local.env_vars.locals.aws_provider_version
  environment          = local.env_vars.locals.tags.environment
  aws_region           = local.region_vars.locals.aws_region
  default_tags         = merge(local.common_tags.locals.tags, local.env_vars.locals.tags)
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = templatefile("provider.tf.tpl", {
    aws_region   = local.aws_region
    default_tags = local.default_tags
  })
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
generate "backend.tf" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = templatefile("backend.tf.tpl", {
    environment         = local.environment
    bucket              = "${local.s3_bucket_prefix}-${local.environment}-${local.aws_region}"
    aws_region          = local.aws_region
    key                 = local.s3_bucket_key_path
    dynamodb            = "${local.dynamodb_prefix}-${local.environment}-${local.aws_region}"
    s3_bucket_tags      = local.default_tags
    dynamodb_table_tags = local.default_tags
  })
}

# Configure AWS provider version
generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        aws = {
          version = "${local.aws_provider_version}"
        }
      }
    }
EOF
}
