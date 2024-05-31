output "vpc_id" {
  value = jsondecode(data.aws_ssm_parameter.ssm-read.value)
}