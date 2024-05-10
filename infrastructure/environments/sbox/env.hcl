locals {
  tags = {
    environment = "sbox"
  }
  aws_provider_version = "~> 5.0"

  account_id = "082372472775"
  oidc = "6DA95E2866E9ADA3DF845862CE133FA8"
  argocd_namespace = "argocd"

  repositories_suffix_admin   = "*"
  repositories_suffix_tf_plan = "*"
}