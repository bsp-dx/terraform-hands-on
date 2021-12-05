module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-v1.0.0"

  context = {
    aws_profile = "terran"
    region      = "ap-northeast-2"
    project     = "waffle"
    environment = "Production"
    owner       = "owner@academyiac.ml"
    team        = "DX"
    cost_center = "20211129"
    domain      = "academyiac.cf"
    pri_domain  = "mydemo.local"
  }
}

data "aws_availability_zones" "this" {
  state = "available"
}

module "vpc" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-vpc-v1.0.0"

  context = module.ctx.context
  cidr    = "171.2.0.0/16"

  azs = [data.aws_availability_zones.this.zone_ids[0], data.aws_availability_zones.this.zone_ids[1]]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_names  = ["pub-a1", "pub-b1"]
  public_subnets       = ["171.2.11.0/24", "171.2.12.0/24"]
  public_subnet_suffix = "pub"

  private_subnet_names = ["was-a1", "was-b1"]
  private_subnets      = ["171.2.31.0/24", "171.2.32.0/24"]

  create_private_domain_hostzone = false

  depends_on = [module.ctx]
}

module "ecs" {
  # source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-ecs-v1.0.0"
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git"

  context            = module.ctx.context
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  container_insights = true

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]

  depends_on = [module.vpc]
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-test"
  requires_compatibilities = ["FARGATE", "EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = module.ecs.ecs_task_execution_role_arn
  cpu                      = 512
  memory                   = 1024
  container_definitions    = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:latest",
    "networkMode" : "awsvpc",
    "essential": true,
    "cpu": 512,
    "memory": 1024,
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ]
  }
]
EOF

  tags       = merge(module.ctx.tags, { Name = "nginx-test" })
  depends_on = [module.ecs]
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

data "aws_subnet_ids" "was" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "tag:Name"
    values = [format("%s-was*", module.ctx.name_prefix)]
  }
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-test-service"
  cluster         = module.ecs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.nginx.id
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = module.alb.target_group_arns[0]
  }

  network_configuration {
    assign_public_ip = false
    subnets          = toset(data.aws_subnet_ids.was.ids)
    security_groups  = [aws_security_group.public_alb.id]
  }

  tags = merge(module.ctx.tags, { Name = "nginx-test-service" })

  depends_on = [aws_ecs_task_definition.nginx]
}
