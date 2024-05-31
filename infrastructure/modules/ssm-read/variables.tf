variable "ssm_vpc_path" {
    description = "path to vpc_id in AWS SSM Parameter Store"
    sensitive = true
    type = string
}

variable "ssm_sn_path" {
    description = "path to database subnets id in AWS SSM Parameter Store"
    sensitive = true
    type = string
}