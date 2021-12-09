data "aws_availability_zones" "this" {
  state = "available"
}

module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-v1.0.0"

  context = {
    aws_profile = "terran"
    region      = "ap-northeast-2"
    project     = "noodle"
    environment = "Education"
    owner       = "owner@academyiac.ml"
    team        = "DevOps"
    cost_center = "20211120"
    domain      = "academyiac.cf"
    pri_domain  = "noodle.local"
  }

  additional_tags = {
    "bsp:tfmodule-aws"     = "elasticache"
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


locals {
  sg_name = "${module.ctx.name_prefix}-redis-sg"
}

resource "aws_security_group" "redis" {
  name        = local.sg_name
  description = "Allow Apps inbound traffic for AWS Elasticache Redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Elasticache-Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.sg_name })
}

module "redis" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-elasticache-redis-v1.0.0"

  context            = module.ctx.context
  vpc_id             = module.vpc.vpc_id
  availability_zones = [
    data.aws_availability_zones.this.names[0],
    data.aws_availability_zones.this.names[1],
  ]

  subnet_ids                       = module.vpc.database_subnets
  security_group_ids               = [aws_security_group.redis.id]
  cluster_mode_enabled             = false
  cluster_size                     = 2
  instance_type                    = "cache.t3.small"
  apply_immediately                = true
  automatic_failover_enabled       = true
  engine_version                   = "6.x"
  family                           = "redis6.x"
  port                             = 6379
  at_rest_encryption_enabled       = false
  transit_encryption_enabled       = true
  cloudwatch_metric_alarms_enabled = false

  parameter = [
    {
      name  = "activerehashing"
      value = "yes"
    }
  ]

  depends_on = [module.vpc]
}
