provider "aws" {
  region              = "${aws_region}"
  default_tags {
    tags = {
%{for name, value in default_tags~}
      ${name} = "${value}"
%{endfor~}
    }
  }
}