data "aws_availability_zones" "this" {
  state = "available"
}

module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-v1.0.0"

  context = {
    aws_profile = "terran"
    region      = "ap-northeast-2"
    project     = "sample-vpc"
    environment = "Education"
    owner       = "owner@bespinglobal.com"
    team        = "DevOps"
    cost_center = "20211120"
    domain      = "simitsme.ml"
    pri_domain  = "sample-vpc.local"
  }

  additional_tags = {
    "bsp:tfmodule-aws"     = "vpc"
    "bsp:tfmodule-version" = "v1.0.0"
  }
}


module "vpc" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-vpc-v1.0.0"

  context = module.ctx.context
  cidr    = "172.76.0.0/16"
  azs     = [data.aws_availability_zones.this.zone_ids[0], data.aws_availability_zones.this.zone_ids[1]]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnets       = ["172.76.11.0/24", "172.76.12.0/24"]
  public_subnet_names  = ["pub-a1", "pub-b1"]
  public_subnet_suffix = "pub"

  private_subnet_names = [
    "web-a1", "web-b1",
    "was-a1", "was-b1",
  ]
  private_subnets      = [
    "172.76.21.0/24", "172.76.22.0/24",
    "172.76.31.0/24", "172.76.32.0/24",
  ]

  database_subnets       = ["172.76.91.0/24", "172.76.92.0/24"]
  database_subnet_names  = ["data-a1", "data-b1"]
  database_subnet_suffix = "data"
  database_subnet_tags   = { "grp:Name" = "${module.ctx.name_prefix}-data" }

  depends_on = [module.ctx]
}
