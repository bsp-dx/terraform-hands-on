data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

data "aws_subnets" "was" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-was*"]
  }
}

data "aws_subnet" "was" {
  for_each = toset(data.aws_subnets.was.ids)
  id       = each.value
}
