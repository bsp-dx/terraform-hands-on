module "ctx" {
  source = "../context"
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = data.aws_ecs_cluster.ecs_web.cluster_name
  task_definition = data.aws_ecs_task_definition.nginx.id
  launch_type     = "EC2"
  desired_count   = 1

  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = data.aws_alb_target_group.web.arn
  }

  network_configuration {
    assign_public_ip = false
    subnets          = toset(data.aws_subnet_ids.web.ids)
    security_groups  = [data.aws_security_group.web.id]
  }

}