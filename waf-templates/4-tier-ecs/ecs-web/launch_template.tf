module "web_lt" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-launchtemplate-v1.0.0"

  context                     = module.ctx.context
  image_id                    = data.aws_ami.web.id
  instance_type               = "t3.large"
  name                        = "web"
  security_groups             = [aws_security_group.web.id]
  user_data_base64            = base64encode(data.template_file.web.rendered)
  create_iam_instance_profile = true
}