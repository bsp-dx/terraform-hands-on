# tfmodule-aws-ecs

AWS ECS 컨테이너 오케스트레이션 서비스를 구성 하는 테라폼 모듈 입니다.

## [ECS](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/Welcome.html)
ECS 는 AWS 의 다양한 서비스(기능)들과 통합과 빠르고 쉽게 구성이 가능합니다.

컨테이너 오케스트레이션 도구로는 AWS 이외에도 Docker Swarm, Kubernetes, 하시코프의 Nomad 등 오픈소스가 있습니다.

### [Fargate 시작 유형](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/launch_types.html)

Fargate 시작 유형은 프로비저닝 없이 컨테이너화된 애플리케이션을 실행하고 백엔드 인프라를 관리할 때 사용할 수 있습니다. AWS Fargate은 서버리스 방식으로 Amazon ECS 워크로드를 호스팅할 수 있습니다.

![ECS Fargate](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/images/overview-fargate.png)


### [EC2 시작 유형](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/launch_types.html)

EC2 시작 유형은 Amazon ECS 클러스터를 등록하고 직접 관리하는 Amazon EC2 인스턴스에서 컨테이너화된 애플리케이션을 실행하는 데 사용할 수 있습니다.

![ECS EC2](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/developerguide/images/overview-standard.png)


## Usage

```
module "ecs_fargate" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-aws-ecs"

  context = module.ctx.context
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  container_insights = true

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
    }
  ]
}

```

## Input Variables

| Name | Description | Type | Example | Required |
|------|-------------|------|---------|:--------:|
| capacity_providers | capacity providers 는 작업 및 서비스를 실행하는 데 필요한 가용성, 확장성 및 비용을 개선합니다. 유효한 capacity provider 는 FARGATE 및 FARGATE_SPOT 입니다. | list(string) | ["FARGATE", "FARGATE_SPOT"] | No |
| default_capacity_provider_strategy | 클러스터에 기본적으로 사용할 capacity_providers 전략입니다. | list(map(any)) | {} | No |
| enable_lifecycle_policy | 리포지토리에 수명 주기 정책의 추가 여부를 설정 합니다. | bool | false| No |
| scan_images_on_push | 이미지가 저장소로 푸시된 후 스캔 여부를 설정 합니다. | bool | true| No |
| principals_full     | ECR 저장소의 전체 액세스 권한을 가지는 IAM 리소스 ARN 입니다. | list(string) | ["arn:aws:iam::111111:user/apple_arn","arn:aws:iam::111111:role/admin_arn"] | No |
| principals_readonly | ECR 저장소의 읽기 전용 IAM 리소스 ARN 입니다. | list(string) | ["*"] | No |
| tags | ECR 저장소의 태그 속성을 정의 합니다. | obejct({}) | <pre>{<br>    Project = "simple"<br>    Environment = "Test"<br>    Team = "DX"<br>    Owner = "symplesims@email.com"<br>}</pre> | Yes |
| name | ECS 클러스터 이름을 정의 합니다. | string | - | No |
| container_insights | ECS 클러스터의 컨테이너 정보를 식별하기 위해 CloudWatch 로그 그룹에 적재 할지 여부입니다. | bool | false | No |

 
## Output Values

| Name | Description | 
|------|-------------|---------| 
| ecs_cluster_id  | ID of the ECS Cluster |
| ecs_cluster_arn | ARN of the ECS Cluster | 
| ecs_cluster_name| The name of the ECS cluster | 
