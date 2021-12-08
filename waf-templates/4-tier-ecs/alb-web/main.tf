module "ctx" {
  source = "../context"
}

module "alb_web" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-alb-v1.0.0"

  context            = module.ctx.context
  lb_name            = "web"
  internal           = true
  load_balancer_type = "application"
  vpc_id             = data.aws_vpc.this.id
  security_groups    = [aws_security_group.web.id]
  subnets            = data.aws_subnet_ids.lbweb.ids

  target_groups = [
    {
      name             = "was-tg8080"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
    },
    {
      name             = "was-tg8088"
      backend_protocol = "HTTP"
      backend_port     = 8088
      target_type      = "ip"
    },
  ]

  http_tcp_listeners = [
    {
      port               = 8080
      protocol           = "HTTP"
      target_group_index = 0
    },
    {
      port               = 8088
      protocol           = "HTTP"
      target_group_index = 1
    },
  ]

}
