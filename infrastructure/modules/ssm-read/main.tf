# Read the first parameter from AWS SSM
data "aws_ssm_parameter" "ssm_vpc" {
  name = var.ssm_vpc_path
}

# Read the second parameter from AWS SSM
data "aws_ssm_parameter" "ssm_sn" {
  name = var.ssm_sn_path
}

output "vpc_id" {
  value = data.aws_ssm_parameter.ssm_vpc.value
  sensitive = true
}

output "ssm_sn_id" {
  value = data.aws_ssm_parameter.ssm_sn.value
  sensitive = true
}