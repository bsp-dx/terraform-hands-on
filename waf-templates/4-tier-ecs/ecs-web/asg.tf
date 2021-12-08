module "asg_web" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-autoscaling-v1.0.0"

  context                    = module.ctx.context
  name                       = "web"
  vpc_zone_identifier        = toset(data.aws_subnets.web.ids)
  launch_template_name       = module.web_lt.launch_template_name
  launch_template_version    = module.web_lt.launch_template_latest_version
  desired_capacity           = 1
  min_size                   = 1
  max_size                   = 6
  create_service_linked_role = true
  force_delete               = true
}
