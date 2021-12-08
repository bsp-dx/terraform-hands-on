data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

data "aws_subnet_ids" "web" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-web*"]
  }
}

data "aws_alb_target_group" "web" {
  name = "${module.ctx.project}-web-tg80"
}

data "aws_security_group" "web" {
  name = "${module.ctx.name_prefix}-ecs-web-sg"
}

data "aws_ecs_cluster" "ecs_web" {
  cluster_name = format("%s-web-ecs", module.ctx.name_prefix)
}

data "aws_ecs_task_definition" "nginx" {
  task_definition = "nginx"
}