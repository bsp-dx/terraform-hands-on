module "asg" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-autoscaling-v1.0.0"

  context                    = module.ctx.context
  name                       = "was"
  vpc_zone_identifier        = toset(data.aws_subnets.was.ids)
  launch_template_name       = module.lt.launch_template_name
  launch_template_version    = module.lt.launch_template_latest_version
  desired_capacity           = 1
  min_size                   = 1
  max_size                   = 10
  create_service_linked_role = true
  force_delete               = true
}
