module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-v1.0.0"

  context = {
    aws_profile  = "terran"
    region       = "ap-northeast-2"
    project      = "melon"
    environment = "Education"
    owner       = "owner@bespinglobal.com"
    team        = "DevOps"
    cost_center = "20211120"
    domain      = "simitsme.ml"
    pri_domain  = "melon.local"
  }

  additional_tags = {
    "bsp:WAF-Template" = "ECS 4-Tier"
    "bsp:WAF-Version"  = "1.0"
  }
}

output "context" {
  value = module.ctx.context
}

output "name_prefix" {
  value = module.ctx.name_prefix
}

output "cluster_name" {
  value = "${module.ctx.name_prefix}-ecs"
}

output "tags" {
  value = module.ctx.tags
}

output "region" {
  value = module.ctx.region
}

output "region_alias" {
  value = module.ctx.region_alias
}

output "project" {
  value = module.ctx.project
}

output "environment" {
  value = module.ctx.environment
}

output "env_alias" {
  value = module.ctx.env_alias
}

output "owner" {
  value = module.ctx.owner
}

output "team" {
  value = module.ctx.team
}

output "cost_center" {
  value = module.ctx.cost_center
}

output "domain" {
  value = module.ctx.domain
}

output "pri_domain" {
  value = module.ctx.pri_domain
}
