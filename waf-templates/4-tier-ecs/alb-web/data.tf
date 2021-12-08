data "aws_acm_certificate" "this" {
  domain = module.ctx.domain
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

data "aws_subnet_ids" "lbweb" {
  vpc_id = data.aws_vpc.this.id

  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-lbweb*"]
  }
}

data "aws_security_group" "pub" {
  name = "${module.ctx.name_prefix}-pub-alb-sg"
}