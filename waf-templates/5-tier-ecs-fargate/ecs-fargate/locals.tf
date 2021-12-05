locals {
  name_prefix = module.ctx.name_prefix
  waf_alb_sg_name  = "${local.name_prefix}-waf-alb-sg"
  web_alb_sg_name = "${local.name_prefix}-web-alb-sg"
  was_alb_sg_name = "${local.name_prefix}-was-alb-sg"
}
