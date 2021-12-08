module "ctx" {
  source = "../context"
}

data "aws_availability_zones" "this" {
  state = "available"
}

module "vpc" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-vpc-v1.0.0"

  context = module.ctx.context
  cidr    = "172.74.0.0/16"
  azs     = [data.aws_availability_zones.this.zone_ids[0], data.aws_availability_zones.this.zone_ids[1]]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnets       = ["172.74.11.0/24", "172.74.12.0/24"]
  public_subnet_names  = ["pub-a1", "pub-b1"]
  public_subnet_suffix = "pub"

  private_subnet_names = [
    "web-a1", "web-b1",
    "was-a1", "was-b1",
    "lbweb-a1", "lbweb-b1",
  ]
  private_subnets      = [
    "172.74.31.0/24", "172.74.32.0/24",
    "172.74.41.0/24", "172.74.42.0/24",
    "172.74.51.0/24", "172.74.52.0/24",
  ]

  database_subnets       = ["172.74.91.0/24", "172.74.92.0/24"]
  database_subnet_names  = ["data-a1", "data-b1"]
  database_subnet_suffix = "data"
  database_subnet_tags   = { "grp:Name" = "${module.ctx.name_prefix}-data" }

  depends_on = [module.ctx]
}
