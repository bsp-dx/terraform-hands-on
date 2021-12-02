module "ctx" {
  source = "../context"
}

data "aws_availability_zones" "this" {
  state = "available"
}

module "vpc" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-aws-vpc"

  context = module.ctx.context
  cidr    = "${var.vpc_cidr}.0.0/16"

  enable_dns_hostnames = true

  azs = [ data.aws_availability_zones.this.zone_ids[0], data.aws_availability_zones.this.zone_ids[1] ]

  public_subnets       = ["${var.vpc_cidr}.11.0/24", "${var.vpc_cidr}.12.0/24"]
  public_subnet_names  = ["pub-a1", "pub-b1"]
  public_subnet_suffix = "pub"
  public_subnet_tags   = {
    "shared.service.network" = 1
    "kubernetes.io/role/elb" = 1
  }

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_names = [
    "waf-a1", "waf-b1",
    "web-a1", "web-b1",
    "was-a1", "was-b1",
    "lbweb-a1", "lbweb-b1",
    "lbwas-a1", "lbwas-b1",
  ]
  private_subnets      = [
    "${var.vpc_cidr}.31.0/24", "${var.vpc_cidr}.32.0/24",
    "${var.vpc_cidr}.41.0/24", "${var.vpc_cidr}.42.0/24",
    "${var.vpc_cidr}.51.0/24", "${var.vpc_cidr}.52.0/24",
    "${var.vpc_cidr}.61.0/24", "${var.vpc_cidr}.62.0/24",
    "${var.vpc_cidr}.71.0/24", "${var.vpc_cidr}.72.0/24",
  ]

  private_subnet_tags = {
    "shared.service.network" = 1
    "kubernetes.io/role/internal-elb" = 1
  }

  database_subnets       = ["${var.vpc_cidr}.91.0/24", "${var.vpc_cidr}.92.0/24"]
  database_subnet_names  = ["data-a1", "data-b1"]
  database_subnet_suffix = "data"
  database_subnet_tags   = { "grp:Name" = "${module.ctx.name_prefix}-data" }

  depends_on = [module.ctx]
}
