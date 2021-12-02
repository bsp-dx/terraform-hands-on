data "aws_acm_certificate" "this" {
  domain = module.ctx.domain
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
}

data "aws_subnet_ids" "waf" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = [format("%s-waf*", module.ctx.name_prefix)]
  }
}

data "aws_subnet_ids" "web" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = [format("%s-web*", module.ctx.name_prefix)]
  }
}
