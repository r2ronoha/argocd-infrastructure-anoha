data "aws_ssm_parameters_by_path" "ssm-read" {
  path = var.path
}