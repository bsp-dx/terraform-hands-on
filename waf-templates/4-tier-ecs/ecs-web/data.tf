data "aws_iam_role" "ecs_sl_role" {
  name = "AWSServiceRoleForECS"
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", module.ctx.name_prefix)]
  }
}

data "aws_subnets" "web" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = [format("%s-web*", module.ctx.name_prefix)]
  }
}

data "aws_ami" "web" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "template_file" "web" {
  template = file("${path.module}/templates/userdata-web.tpl")
  vars     = {
    cluster_name = "${module.ctx.name_prefix}-web-ecs"
  }
}