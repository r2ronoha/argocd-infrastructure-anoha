output "vpc_id" {
  value = data.aws_ssm_parameters_by_path.ssm-read.outputs.vpc_id
}

output "database_subnets" {
  value = data.aws_ssm_parameters_by_path.ssm-read.outputs.subnets.db_sn_ids
}