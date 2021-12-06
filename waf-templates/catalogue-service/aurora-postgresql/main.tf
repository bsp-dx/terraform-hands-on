locals {
  db_subnet_group_name = format("%s-data-sng", module.ctx.name_prefix )
  was_allowed_cidr_blocks = [for s in data.aws_subnet.was : s.cidr_block]
}

module "ctx" {
  source = "./context"
}

module "aurora" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-rds-aurora-v1.0.0"

  context               = module.ctx.context
  engine                = "aurora-postgresql"
  engine_version        = "12.7"
  instance_type         = "db.r5.large"
  instance_type_replica = "db.t3.medium"
  vpc_id                = data.aws_vpc.this.id
  db_subnet_group_name  = local.db_subnet_group_name
  create_security_group = true
  publicly_accessible   = false
  allowed_cidr_blocks   = toset(local.was_allowed_cidr_blocks)
  replica_count         = 2
  username              = "root"
  password              = var.aurora_db_password
  apply_immediately     = false
  skip_final_snapshot   = true
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  cluster_tags = {
    "bsp:CatalogueService" = "RDS Aurora Postgresql"
  }

  depends_on = [data.aws_vpc.this]
}
