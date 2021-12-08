module "ctx" {
  source = "../context"
}

locals {
  project     = module.ctx.project
  name_prefix = module.ctx.name_prefix
  tags        = module.ctx.tags
}

resource "aws_ecs_capacity_provider" "web_provider" {
  name = "WAS"
  auto_scaling_group_provider {
    auto_scaling_group_arn = module.asg.autoscaling_group_arn
  }
}

module "ecs_web" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-ecs-v1.0.0"

  context            = module.ctx.context
  middle_name        = "was"
  container_insights = false

  capacity_providers = [
    aws_ecs_capacity_provider.web_provider.name,
  ]

  default_capacity_provider_strategy = [
    {
      capacity_provider = aws_ecs_capacity_provider.web_provider.name
      weight            = 1
    },
  ]

  depends_on = [aws_ecs_capacity_provider.web_provider]
}