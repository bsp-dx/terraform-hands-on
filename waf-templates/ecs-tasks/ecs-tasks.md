# ECS Task Definition

Amazon ECS 클러스터에서 Docker 컨테이너를 실행하려면 태스크 정의(Task Definition)가 필요합니다.


## 주요 리소스

ECS 작업 정의를 위해 IAM 및 ECS Task 를 구성 합니다.

|  Service          | Resource              |  Description |
| :-------------:   | :-------------        | :----------- |
| IAM               | Role                  | ECS 클러스터가 작업 실행을 위한 execution role 로 "ecs-tasks.amazonaws.com" 의 AssumeRole 및 Policy 를 구성 합니다. |
| ECS               | Task                  | ECS 클러스터가 애플리케이션 론칭에 참조할 작업 을 구성 합니다. frontend, backend 등의 애플리케이션 배치를 위한 작업을 구성 합니다. |   

## Build

### Checkout

git clone 명령으로 프로젝트를 체크 아웃 합니다.

```
git clone https://github.com/bsp-dx/terraform-hands-on.git
```

### 프로젝트 환경 변수 설정

WAF_PROJECT_HOME 프로젝트 홈 경로를 위한 환경 변수를 설정 합니다.

```
export WAF_PROJECT_HOME=$(pwd -P)/terraform-hands-on/waf-templates/ecs-tasks
```

### ECS Task Definition

ECS Task Definition 을 생성 합니다.

```
cd ${WAF_PROJECT_HOME}/tasks

terraform init
terraform plan
terraform apply
```

## Destroy

ECS Task Definition 을 제거 합니다.

```
cd ${WAF_PROJECT_HOME}/tasks

terraform deploy
```

## 작업 정의 샘플

작업 정의 속성 중 리소스에 해당하는 cpu, memory 에서 memory 값은 cpu 값의 2배에 해당하는 값을 입력 해야 합니다. cpu 값이 512 라면 memory 값은 1024 여야 합니다. 작업 정의를
생성 하기 위해선 "ecsTaskExecutionRole" IAM 역할이 사전에 생성 되어 있어야 합니다.

```
data "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole" 
}

resource "aws_ecs_task_definition" "my-ecs-service" {
  family                   = "my-ecs-service"
  requires_compatibilities = ["FARGATE", "EC2"]
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 512
  memory                   = 1024
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
```

## ECS 서비스 론칭 샘플

```
# 사전에 nginx 작업 정의가 생성되어 있어야 합니다.
data "aws_ecs_task_definition" "nginx" {
  task_definition = "nginx"
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = <cluster_id>
  task_definition = data.aws_ecs_task_definition.nginx.id
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = <target_group_arn>
  }

  network_configuration {
    assign_public_ip = false
    subnets          = <subnet_ids>
    security_groups  = [ <security_group_id> ]
  }

  tags = {
    Name = "nginx-service"
    ...
  }
}
```