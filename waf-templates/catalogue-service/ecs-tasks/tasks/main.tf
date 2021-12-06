module "ecs_role" {
  source = "../iam-role"
}

resource "aws_ecs_task_definition" "nginx" {
  count                    = var.create_nginx ? 1 : 0
  family                   = "nginx"
  requires_compatibilities = ["FARGATE", "EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = module.ecs_role.ecs_task_execution_role_arn
  cpu                      = 512
  memory                   = 1024
  container_definitions    = <<EOF
[
  {
    "name": "nginx",
    "image": "nginx:latest",
    "networkMode" : "awsvpc",
    "essential": true,
    "cpu": 512,
    "memory": 1024,
    "portMappings": [
      {
        "protocol": "tcp",
        "hostPort": 80,
        "containerPort": 80
      }
    ]
  }
]
EOF

  tags = {
    "app:Name"    = "nginx"
    "app:Version" = "1.0"
  }

  depends_on = [module.ecs_role]
}

resource "aws_ecs_task_definition" "golang-service" {
  count                    = var.create_golang_api ? 1 : 0
  family                   = "golang-service"
  requires_compatibilities = ["FARGATE", "EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = module.ecs_role.ecs_task_execution_role_arn
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<EOF
[
  {
    "name": "golang-service",
    "image": "symplesims/sample-golang-service:1.0.0",
    "networkMode" : "awsvpc",
    "essential": true,
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "protocol": "tcp",
        "hostPort": 8080,
        "containerPort": 8080
      }
    ]
  }
]
EOF

  tags = {
    "app:Name"    = "golang-service"
    "app:Version" = "1.0.0"
  }

  depends_on = [module.ecs_role]

}