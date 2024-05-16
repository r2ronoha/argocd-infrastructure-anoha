locals {
  tags = {
    environment = "staging"
  }
  aws_provider_version = "~> 5.0"

  account_id       = "851725295329"
  oidc             = "12A6F7DC621CDAA2A2A63CE55D4530E9"
  argocd_namespace = "argocd"
}