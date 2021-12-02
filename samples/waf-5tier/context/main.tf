module "ctx" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-context"

  context = {
    aws_profile = "terran"
    region      = "ap-northeast-2"
    project     = "apple5t"
    environment = "VPC-1Tier"
    owner       = "owner.dx@bespinglobal.com"
    team_name   = "Devops Transformation"
    team        = "DX"
    cost_center = "20211129"
    domain      = "simitsme.ml"
    pri_domain  = "apple5t.local"
  }
}

output "context" {
  value = module.ctx.context
}

output "name_prefix" {
  value = module.ctx.name_prefix
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
