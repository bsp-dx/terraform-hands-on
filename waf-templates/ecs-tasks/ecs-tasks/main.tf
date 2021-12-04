module "ctx" {
  source = "../../5-tier-vpc-waf/context"
}

resource "aws_ecs_task_definition" "nginx" {
  count                    = var.create_nginx ? 1 : 0
  family                   = "nginx"
  requires_compatibilities = ["FARGATE", "EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.main_ecs_tasks.arn
  cpu                      = 512
  memory                   = 1024
  container_definitions    = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:latest",
    "networkMode" : "awsvpc",
    "essential": true,
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ]
  }
]
EOF

  tags = merge(local.tags, { Name = "nginx" })

  depends_on = [aws_iam_role.main_ecs_tasks]
}
