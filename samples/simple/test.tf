locals {
  ecs_task_role_name = "ecsTaskExecutionRole"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

output "value" {
  value = data.aws_iam_role.ecs_task_execution_role.arn
}

