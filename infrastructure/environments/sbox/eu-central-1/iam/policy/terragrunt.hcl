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
  source = "github.com/terraform-aws-modules/terraform-aws-iam//wrappers/iam-policy?ref=v5.39.0"
}

inputs = {
  items = {
    argocd_secret = {
      name        = "argocd-infrastructure-secret-${local.env_vars.locals.tags.environment}"
      description = "Policy for argocd-infrastructure to access external secrets"

      policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:DescribeParameters",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          "Resource": "*"
        }
    EOF
    }

    argocd_cluster = {
      name        = "argocd-infrastructure-cluster-${local.env_vars.locals.tags.environment}"
      description = "Policy for argocd-infrastructure to communicate with registered clusters"
      path        = "/"

      policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Resource": "arn:aws:iam::*:role/ArgoCDClusterRole-*",
          "Effect": "Allow"
        }
    EOF
    }
  }
}
