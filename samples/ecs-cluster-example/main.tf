module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-v1.0.0"

  context = {
    aws_profile = "terran"
    region      = "ap-northeast-2"
    project     = "hamburger"
    environment = "PoC"
    owner       = "owner@academyiac.cf"
    team        = "DX"
    cost_center = "20211120"
    domain      = "academyiac.cf"
    pri_domain  = "hamburger.local"
  }
}

data "aws_availability_zones" "this" {
  state = "available"
}

module "vpc" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-vpc-v1.0.0"

  context = module.ctx.context
  cidr    = "172.5.0.0/16"

  azs = [data.aws_availability_zones.this.zone_ids[0], data.aws_availability_zones.this.zone_ids[1]]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_names  = ["pub-a1", "pub-b1"]
  public_subnets       = ["172.5.11.0/24", "172.5.12.0/24"]
  public_subnet_suffix = "pub"
  private_subnet_names = ["was-a1", "was-b1"]
  private_subnets      = ["172.5.31.0/24", "172.5.32.0/24"]
  create_private_domain_hostzone = false

  depends_on = [module.ctx]
}

data "aws_ami" "tasksboard" {
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


locals {
  cluster_name        = "${module.ctx.name_prefix}-ecs"
  tasksboard_userdata = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${local.cluster_name} >> /etc/ecs/ecs.config;

EOF
}

module "lt_tasksboard" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-launchtemplate-v1.0.0"

  context                     = module.ctx.context
  image_id                    = data.aws_ami.tasksboard.id
  instance_type               = "m5.large"
  name                        = "tasksboard"
  user_data_base64            = base64encode(local.tasksboard_userdata)
  create_iam_instance_profile = true
}


module "autoscaling" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-autoscaling-v1.0.0"

  context                    = module.ctx.context
  name                       = "tasksboard"
  launch_template_name       = module.lt_tasksboard.launch_template_name
  launch_template_version    = module.lt_tasksboard.launch_template_latest_version
  vpc_zone_identifier        = toset(module.vpc.public_subnets)
  desired_capacity           = 1
  min_size                   = 1
  max_size                   = 8
  create_service_linked_role = true
}

resource "aws_ecs_capacity_provider" "tasksboard" {
  name = "tasksboard"
  auto_scaling_group_provider {
    auto_scaling_group_arn = module.autoscaling.autoscaling_group_arn
  }
}

resource "aws_security_group" "public_alb" {
  name        = "${module.ctx.name_prefix}-pub-alb-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = "${module.ctx.name_prefix}-pub-alb-sg" })
}

module "alb" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-alb-v1.0.0"

  context            = module.ctx.context
  lb_name            = "pub"
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = toset(module.vpc.public_subnets)
  security_groups = [aws_security_group.public_alb.id]

  target_groups = [
    {
      name             = "nginx-tg80"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check     = {
        path              = "/"
        healthy_threshold = 2
        protocol          = "HTTP"
        matcher           = "200-302"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  depends_on = [module.vpc]
}


module "ecs" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-ecs-v1.0.0"

  context            = module.ctx.context
  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.tasksboard.name]
  container_insights = false

  default_capacity_provider_strategy = [
    {
      capacity_provider = aws_ecs_capacity_provider.tasksboard.name
      weight            = 1
    }
  ]

  depends_on = [module.vpc, module.autoscaling]
}
