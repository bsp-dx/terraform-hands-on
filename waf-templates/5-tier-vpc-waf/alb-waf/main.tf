module "ctx" {
  source = "../context"
}

# IGW to WAF
module "alb_waf" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-alb-v1.0.0"

  context            = module.ctx.context
  lb_name            = "waf"
  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.this.id
  subnets         = data.aws_subnet_ids.public.ids
  security_groups = [aws_security_group.public_alb.id]

  target_groups = [
    {
      name             = "waf-tg80"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.this.arn
      target_group_index = 0
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      priority             = 1
      actions              = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions           = [
        {
          path_patterns = ["/*"]
        }
      ]
    },
    {
      https_listener_index = 0
      priority             = 2
      actions              = [
        {
          type               = "forward",
          target_group_index = 0
        }
      ]
      conditions           = [
        {
          host_headers = [format("web.%s", module.ctx.domain)]
        }
      ]
    },
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect    = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

}
