data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-vpc"]
  }
}

# nginx-service 가 배치될 서브넷
data "aws_subnet_ids" "web" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-web*"]
  }
}

# nginx-service 와 연결된 ALB 의 타겟 그룹
data "aws_alb_target_group" "web" {
  name = "${module.ctx.project}-web-tg80"
}

# nginx-service 의 보안 그룹
data "aws_security_group" "web" {
  name = "${module.ctx.name_prefix}-web-alb-sg"
}

# nginx-service 가 배포 될 ECS 클러스터 이름
data "aws_ecs_cluster" "ecs_web" {
  cluster_name = format("%s-%s-ecs", module.ctx.name_prefix, "web")
}

# nginx-service 의 ECS 작업 정의 이름
data "aws_ecs_task_definition" "nginx" {
  task_definition = "nginx"
}