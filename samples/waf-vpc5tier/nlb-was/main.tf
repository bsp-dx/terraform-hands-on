module "ctx" {
  source = "../context"
}

module "nlb_was" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-aws-alb"

  context            = module.ctx.context
  lb_name            = "was"
  internal           = true
  load_balancer_type = "network"

  vpc_id  = data.aws_vpc.this.id
  subnets = data.aws_subnet_ids.lbwas.ids

  target_groups = [
    {
      name             = "was-tg8080"
      backend_protocol = "TCP"
      backend_port     = 8080
      target_type      = "ip"
      health_check     = {
        path     = "/health"
        protocol = "HTTP"
      }
    },
    {
      name             = "rds-tg3306"
      backend_protocol = "TCP"
      backend_port     = 3306
      target_type      = "ip"
    },
  ]

  http_tcp_listeners = [
    {
      port               = 8080
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 3306
      protocol           = "TCP"
      target_group_index = 1
    },
  ]

}
