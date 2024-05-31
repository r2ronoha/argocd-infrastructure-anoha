data "aws_ssm_parameter" "ssm-read" {
  name = var.ssm_path
}