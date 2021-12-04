data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [format("%s-vpc", module.ctx.name_prefix)]
  }
}

# WAF Subnet ids 참조
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

############ ECS Cluster ############

data "aws_iam_role" "cluster_sl" {
  name = "AWSServiceRoleForECS"
}

# nginx
data "aws_ecs_task_definition" "nginx" {
  task_definition = "nginx"
}

data "aws_security_group" "waf-alb" {
  name = "${module.ctx.name_prefix}-waf-alb-sg"
}

data "aws_alb_target_group" "waf_tg80" {
  name = "${module.ctx.project}-waf-tg80"
}
