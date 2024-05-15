locals {
  tags = {
    owner                 = "delta"
    owner-email           = "delta@jamf.com"
    project               = "delta infrastructure"
    deployment-repository = "https://github.com/jamf/argocd-infrastructure.git"
    deployment-software   = "terragrunt"
  }
}