resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = module.ecs_fargate.ecs_cluster_id
  task_definition = data.aws_ecs_task_definition.nginx.id
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = data.aws_alb_target_group.waf_tg80.arn
  }

  network_configuration {
    assign_public_ip = false
    subnets          = toset(data.aws_subnets.web.ids)
    security_groups  = [data.aws_security_group.waf-alb.id]
  }

  tags = merge(module.ctx.tags, { Name = "nginx-service" })
}
