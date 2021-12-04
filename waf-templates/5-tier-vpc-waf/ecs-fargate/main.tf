module "ctx" {
  source = "../context"
}

module "ecs_fargate" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-aws-ecs"

  context = module.ctx.context
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  container_insights = true

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]
}
