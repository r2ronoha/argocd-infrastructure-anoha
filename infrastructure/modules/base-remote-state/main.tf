data "terraform_remote_state" "base_remote_state" {
  backend = "s3"
  config = {
    bucket   = var.bucket
    encrypt  = true
    key      = var.key
    region   = var.region
  }
}

output "vpc_id" {
  value = data.terraform_remote_state.base_remote_state.outputs.vpc_id
}

output "database_subnets" {
  value = data.terraform_remote_state.base_remote_state.outputs.database_subnets
}

output "private_subnets" {
  value = data.terraform_remote_state.base_remote_state.outputs.private_subnets
}
