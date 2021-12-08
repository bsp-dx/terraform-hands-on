data "aws_ami" "my_web" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-*"]
  }
}

# 커스텀 user_data
data "template_file" "my_web" {
  template = file("${path.module}/templates/userdata-myweb.tpl")
  vars     = {
    name = "Symplesims"
  }
}

module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-v1.0.0"

  context = {
    aws_profile = "terran"
    region      = "ap-northeast-2"
    project     = "starstory"
    environment = "Learning"
    owner       = "owner@academyiac.ml"
    team_name   = "Devops Transformation"
    team        = "DX"
    cost_center = "20211120"
    domain      = "academyiac.ml"
    pri_domain  = "starstory.local"
  }
}

# Launch Template
module "my_web" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-launchtemplate-v1.0.0"

  context          = module.ctx.context
  image_id         = data.aws_ami.my_web.id
  instance_type    = "t3.small"
  name             = "my_web"
  user_data_base64 = base64encode(data.template_file.my_web.rendered)
}