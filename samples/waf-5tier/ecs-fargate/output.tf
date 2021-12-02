output "ecs_cluster_sl_iam_role_id" {
  value = data.aws_iam_role.cluster_sl.id
}

output "nginx_task_definition_arn" {
  value = data.aws_ecs_task_definition.nginx.id
}