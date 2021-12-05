module "ctx" {
  source = "../context"
}

data "aws_availability_zones" "this" {
  state = "available"
}

/* ~ ----- VPC  ----- */

module "vpc" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-vpc-v1.0.0"

  context = module.ctx.context
  cidr    = "172.52.0.0/16"

  enable_dns_hostnames = true

  azs = [data.aws_availability_zones.this.zone_ids[0], data.aws_availability_zones.this.zone_ids[1]]

  public_subnets       = ["172.52.11.0/24", "172.52.12.0/24"]
  public_subnet_names  = ["pub-a1", "pub-b1"]
  public_subnet_suffix = "pub"
  public_subnet_tags   = {
    "shared.service.network" = 1
    "kubernetes.io/role/elb" = 1
  }

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_names = [
    "waf-a1", "waf-b1",
    "web-a1", "web-b1",
    "was-a1", "was-b1",
    "lbweb-a1", "lbweb-b1",
    "lbwas-a1", "lbwas-b1",
  ]
  private_subnets      = [
    "172.52.31.0/24", "172.52.32.0/24",
    "172.52.41.0/24", "172.52.42.0/24",
    "172.52.51.0/24", "172.52.52.0/24",
    "172.52.61.0/24", "172.52.62.0/24",
    "172.52.71.0/24", "172.52.72.0/24",
  ]

  private_subnet_tags = {
    "shared.service.network"          = 1
    "kubernetes.io/role/internal-elb" = 1
  }

  database_subnets       = ["172.52.91.0/24", "172.52.92.0/24"]
  database_subnet_names  = ["data-a1", "data-b1"]
  database_subnet_suffix = "data"
  database_subnet_tags   = { "grp:Name" = "${module.ctx.name_prefix}-data" }

  depends_on = [module.ctx]
}


/* ~ ----- ALB ----- */

resource "aws_security_group" "waf_alb_sg" {
  name        = local.waf_alb_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from IGW"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from IGW"
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

  tags = merge(module.ctx.tags, { Name = local.waf_alb_sg_name })

  depends_on = [module.vpc]
}

module "alb_waf" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-alb-v1.0.0"

  context            = module.ctx.context
  lb_name            = "pub-waf"
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = toset(module.vpc.public_subnets)
  security_groups = [aws_security_group.waf_alb_sg.id]

  target_groups = [
    {
      name             = "waf-tg80"
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

resource "aws_security_group" "web" {
  name        = local.web_alb_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP 80 for Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ module.vpc.vpc_cidr_block ]
  }

  ingress {
    description = "HTTP 8080 for Backend API"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [ module.vpc.vpc_cidr_block ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.web_alb_sg_name })

  depends_on = [module.vpc]
}

data "aws_subnet_ids" "lbweb" {
  vpc_id     = module.vpc.vpc_id
  filter {
    name   = "tag:Name"
    values = [format("%s-lbweb*", local.name_prefix)]
  }
  depends_on = [module.vpc.private_subnets]
}

module "alb_web" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-alb-v1.0.0"

  context            = module.ctx.context
  lb_name            = "web"
  internal           = true
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  security_groups = [aws_security_group.web.id]
  subnets         = data.aws_subnet_ids.lbweb.ids

  target_groups = [
    {
      name             = "web-tg80"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    },
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  depends_on = [module.vpc]
}

resource "aws_security_group" "was" {
  name        = local.was_alb_sg_name
  description = "Internal ALB WAS SecurityGroup"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [ module.vpc.vpc_cidr_block ]
  }

  ingress {
    description = "RDS 3306"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ module.vpc.vpc_cidr_block ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.was_alb_sg_name })

  depends_on = [module.vpc]
}

data "aws_subnet_ids" "lbwas" {
  vpc_id     = module.vpc.vpc_id
  filter {
    name   = "tag:Name"
    values = [format("%s-lbwas*", local.name_prefix)]
  }
  depends_on = [module.vpc.private_subnets]
}

module "alb_was" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-alb-v1.0.0"

  context            = module.ctx.context
  lb_name            = "was"
  internal           = true
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  security_groups = [aws_security_group.web.id]
  subnets         = data.aws_subnet_ids.lbwas.ids

  target_groups = [
    {
      name             = "was-tg8080"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 8080
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  depends_on = [module.vpc]
}


/* ~ ----- ECS Fargate Cluster ----- */

module "ecs_web" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-ecs-v1.0.0"

  context                        = module.ctx.context
  middle_name                    = "web"
  capacity_providers             = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]

  depends_on = [module.vpc]
}

module "ecs_was" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-ecs-v1.0.0"

  context                        = module.ctx.context
  middle_name                    = "was"
  capacity_providers             = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]

  depends_on = [module.vpc]
}