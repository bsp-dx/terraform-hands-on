module "lt" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-launchtemplate-v1.0.0"

  context                     = module.ctx.context
  image_id                    = data.aws_ami.was.id
  instance_type               = "t3.large"
  name                        = "was"
  security_groups             = [aws_security_group.was.id]
  user_data_base64            = base64encode(data.template_file.was.rendered)
  create_iam_instance_profile = true
}