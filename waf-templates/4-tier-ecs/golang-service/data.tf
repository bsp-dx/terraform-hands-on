data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

data "aws_subnet_ids" "was" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-was*"]
  }
}

data "aws_alb_target_group" "was" {
  name = "${module.ctx.project}-was-tg8080"
}

data "aws_security_group" "was" {
  name = "${module.ctx.name_prefix}-was-sg"
}

data "aws_ecs_cluster" "ecs" {
  cluster_name = format("%s-was-ecs", module.ctx.name_prefix)
}

data "aws_ecs_task_definition" "golang-service" {
  task_definition = "golang-service"
}