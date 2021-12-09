locals {
  db_subnet_group_name    = format("%s-data-sng", module.ctx.name_prefix )
  was_allowed_cidr_blocks = [for s in data.aws_subnet.was : s.cidr_block]
}

module "ctx" {
  source = "./context"
}

module "redis" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-elasticache-redis-v1.0.0"

  context              = module.ctx.context
  vpc_id               = data.aws_vpc.this.id
  availability_zones   = [
    data.aws_availability_zones.this.names[0],
    data.aws_availability_zones.this.names[1],
  ]
  subnet_ids           = data.aws_subnets.data.ids
  security_group_ids   = [aws_security_group.redis.id]
  cluster_mode_enabled = true

  parameter = [
    {
      name  = "activerehashing"
      value = "no"
    },
  ]

  depends_on = [data.aws_vpc.this]
}
