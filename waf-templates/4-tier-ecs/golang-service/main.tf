module "ctx" {
  source = "../context"
}

resource "aws_ecs_service" "golang_service" {
  name            = "golang-service"
  cluster         = data.aws_ecs_cluster.ecs.cluster_name
  task_definition = data.aws_ecs_task_definition.golang-service.id
  launch_type     = "EC2"
  desired_count   = 1

  load_balancer {
    container_name   = "golang-service"
    container_port   = 8080
    target_group_arn = data.aws_alb_target_group.was.arn
  }

  network_configuration {
    assign_public_ip = false
    subnets          = toset(data.aws_subnet_ids.was.ids)
    security_groups  = [data.aws_security_group.was.id]
  }

}