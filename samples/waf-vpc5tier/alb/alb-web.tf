# WAF to WEB
module "alb_web" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-aws-alb"

  context   = module.ctx.context
  lb_name   = "web"
  internal  = true
  load_balancer_type = "application"

  vpc_id          = data.aws_vpc.this.id
  security_groups = [ aws_security_group.internal_alb.id ]
  subnets         = data.aws_subnet_ids.waf.ids

  target_groups = [
    {
      name                 = "web-tg80"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
#      targets = {
#        was = {
#          target_id = aws_instance.was.id
#          port      = 8080
#        }
#      }
    },
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      target_group_index = 0
    },
  ]

}
