locals {
  tags = {
    environment = "production"
  }
  aws_provider_version = "~> 5.0"

  account_id       = "992382493208"
  oidc             = "475F53C06BC1663CB5B66896DD64BBD5"
  argocd_namespace = "argocd-infrastructure"

  secret_recovery = "180"
}