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

      name        = "argocd-secret-${local.env_vars.locals.tags.environment}-${local.region_vars.locals.aws_region}"
      description = "Policy for argocd to access external secrets"

      policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "SSM",
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
        },
        {
          "Sid": "ESO",
          "Effect": "Allow",
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Principal": {
                "Federated": "arn:aws:iam::${local.env_vars.locals.account_id}:oidc-provider/oidc.eks.${local.region_vars.locals.aws_region}.amazonaws.com/id/${local.env_vars.locals.oidc}"
            },
          "Resource": "*",
                "Condition": {
                    "ForAllValues:StringEquals": {
                    "oidc.eks.${local.region_vars.locals.aws_region}.amazonaws.com/id/${local.env_vars.locals.oidc}:sub": [
                        "system:serviceaccount:${local.env_vars.locals.argocd_namespace}:kubernetes-external-secrets**"
                    ]
                }
                "StringLike": {
                    "oidc.eks.${local.region_vars.locals.aws_region}.amazonaws.com/id/${local.env_vars.locals.oidc}:sub": "system:serviceaccount:${local.env_vars.locals.argocd_namespace}:kubernetes-external-secrets**"
                }
              }
       }
     ]
    }
    EOF
    }
    
    argocd_cluster = {

      name        = "argocd-cluster-${local.env_vars.locals.tags.environment}-${local.region_vars.locals.aws_region}"
      description = "Policy for ArgoCD Infrastructure to communicate with registered clusters ({{ ENV }})"

      policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Role"
          "Action": [
            "sts:AssumeRole"
          ],
          "Resource": "arn:aws:iam::*:role/argocd-cluster-*",
          "Effect": "Allow"
        },
        {
        "Sid": "Trust",
        "Effect": "Allow",
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Principal": {
              "Federated": "arn:aws:iam::${local.env_vars.locals.account_id}:oidc-provider/oidc.eks.${local.region_vars.locals.aws_region}.amazonaws.com/id/${local.env_vars.locals.oidc}"
          },
        "Resource": "*",
              "Condition": {
                 "StringLike": {
                    "oidc.eks.${local.region_vars.locals.aws_region}.amazonaws.com/id/${local.env_vars.locals.oidc}:sub": "system:serviceaccount:${local.env_vars.locals.argocd_namespace}*:argocd-application-controller"
              }
            }
       }
      ]
    }
  EOF
    }      
  }
}
