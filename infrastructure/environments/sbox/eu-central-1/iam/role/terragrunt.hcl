locals {
  env_vars            = read_terragrunt_config(find_in_parent_folders("../env.hcl"))
  region_vars         = read_terragrunt_config(find_in_parent_folders("region_vars.hcl"))
}



include {
  path = find_in_parent_folders()
}


dependency "policy" {
  config_path = "../policy"

  mock_outputs_allowed_terraform_commands = ["validate-inputs", "validate", "plan", "output"]
  mock_outputs = {
    wrapper = {
      argocd_secret = {
        arn = "arn:aws:iam::aws:policy/mock" # Mocking policy arn
      }
      argocd_cluster = {
        arn = "arn:aws:iam::aws:policy/mock" # Mocking policy arn
      }
    }
  }
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//wrappers/iam-assumable-role?ref=v5.39.0"
}

inputs = {
  defaults = {
    create_role = true
  }

  items = {
    argocd_secret = {
      role_name                       = "argocd-infrastructure-secret-${local.env_vars.locals.tags.environment}"
      role_description                = "Role for argocd-infrastructure to access external secrets"
      custom_role_policy_arns         = ["${dependency.policy.outputs.wrapper.argocd_secret.arn}"]

      create_custom_role_trust_policy = true
      custom_role_trust_policy        = <<EOF
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": "sts:AssumeRoleWithWebIdentity",
              "Principal": {
                "Federated": "arn:aws:iam::${local.env_vars.locals.account_id}:oidc-provider/oidc.eks.${local.region_vars.locals.aws_region}.amazonaws.com/id/${local.env_vars.locals.oidc}"
              },
              "Resource": "*",
                "Condition": {
                    "ForAllValues:StringEquals": {
                      "oidc.eks.${local.region_vars.locals.aws_region}.amazonaws.com/id/${local.env_vars.locals.oidc}:sub": "system:serviceaccount:${local.env_vars.locals.argocd_namespace}:kubernetes-external-secrets**"
                },
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
      role_name                       = "argocd-infrastructure-cluster-${local.env_vars.locals.tags.environment}"
      role_description                = "Role for argocd-infrastructure to communicate with registered clusters"
      custom_role_policy_arns         = ["${dependency.policy.outputs.wrapper.argocd_cluster.arn}"]

      create_custom_role_trust_policy = true
      custom_role_trust_policy        = <<EOF
        {
          "Version": "2012-10-17",
          "Statement": [
            {
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
