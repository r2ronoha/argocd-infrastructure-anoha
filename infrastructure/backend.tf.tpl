terraform {
  backend "s3" {
    bucket         = "${bucket}"
    encrypt        = true
    dynamodb_table = "${dynamodb}"
    key            = "${key}"
    region         = "${aws_region}"
  }
}