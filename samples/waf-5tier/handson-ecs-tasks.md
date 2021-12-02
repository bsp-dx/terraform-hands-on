# ECS 작업 정의

ECS 클러스터에 론칭 할 애플리케이션 서비스의 배포 작업을 정의 합니다.

## 주요 리소스

ECS 작업 정의를 위해 IAM 및 ECS Task 를 구성 합니다.

|  Service          | Resource              |  Description |
| :-------------:   | :-------------        | :----------- |
| IAM               | Role                  | ECS 클러스터가 작업 실행을 위한 execution role 로 "ecs-tasks.amazonaws.com" 의 AssumeRole 및 Policy 를 구성 합니다. |
| ECS               | Task                  | ECS 클러스터가 애플리케이션 론칭에 참조할 작업 을 구성 합니다. frontend, backend 등의 애플리케이션 배치를 위한 작업을 구성 합니다. |   

## Code

- [ecs-tasks/main.tf](./ecs-tasks/main.tf) - ECS 애플리케이션을 위한 작업을 구성 합니다.
- [ecs-tasks/iam.tf](./ecs-tasks/iam.tf) - ECS 클러스터가 작업 실행을 위한 execution 롤 을 구성 합니다.

## Build

```shell
git clone https://github.com/bsp-dx/terraform-hands-on.git
cd terraform-hands-on/samples/waf-5tier/ecs-tasks

terraform init
terraform plan
terraform apply
```

