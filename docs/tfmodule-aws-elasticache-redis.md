# tfmodule-aws-elasticache-redis

AWS [Elasticache-Redis](https://docs.aws.amazon.com/ko_kr/AmazonElastiCache/latest/red-ug/WhatIs.html) 플랫폼 서비스를 생성 하는 테라폼 모듈
입니다.

Amazon ElastiCache 는 클라우드에서 분산된 인 메모리 데이터 스토어 또는 캐시 환경을 손쉽게 설정, 관리 및 확장할 수 있는 Memory DB 서비스입니다.  
Memory DB를 사용하면 모든 데이터가 메모리에 저장되므로 대기 시간이 짧고 처리량이 높은 데이터 액세스가 가능합니다.

## Usage

```
data "aws_availability_zones" "this" {
  state = "available"
}

module "redis" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-elasticache-redis-v1.0.0"

  context                          = module.ctx.context
  vpc_id                           = module.vpc.vpc_id
  availability_zones               = [
    data.aws_availability_zones.this.names[0],
    data.aws_availability_zones.this.names[1],
  ]
  subnet_ids                       = module.vpc.database_subnets
  security_group_ids               = [aws_security_group.redis.id]
  cluster_mode_enabled             = false
  cluster_size                     = 2
  instance_type                    = "cache.t3.small"
  apply_immediately                = true
  automatic_failover_enabled       = true
  engine_version                   = "6.x"
  family                           = "redis6.x"
  port                             = 6379
  at_rest_encryption_enabled       = false
  transit_encryption_enabled       = true
  cloudwatch_metric_alarms_enabled = false

  parameter = [
    {
      name  = "activerehashing"
      value = "no"
    },
    {
      name  = "active-defrag-threshold-lower"
      value = "10"
    },
    {
      name  = "active-defrag-threshold-upper"
      value = "100"
    }
  ]

  depends_on = [module.vpc]
}

resource "aws_security_group" "redis" {
  name        = <redis-sg-name>
  vpc_id      = module.vpc.vpc_id
  # ... You need to define security-group for redis ...
}

module "vpc" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-vpc-v1.0.0"
  context  = module.ctx.context
  # ... You need to define resources for vpc ...
}

module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-v1.0.0"
  context = {  
    # ... You need to define context variables ...
  }
}
```

### Dependencies Module

- Context 모듈은 [tfmodule-context](./tfmodule-context.md) 가이드를 참고 하세요.
- VPC 모듈은 [tfmodule-aws-vpc](./tfmodule-aws-vpc.md) 가이드를 참고 하세요.

## Input Variables

| Name | Description | Type | Example | Required |
|------|-------------|------|---------|:--------:|
| create_redis | Elasticache Redis 클러스터 생성 여부입니다. | bool | true | No |
| vpc_id | VPC 아이디 입니다. | string | - | Yes |
| middle_name | RDS 클러스터의 중간 이름을 설정 합니다. (여러개의 RDS 클러스터를 구성 하는 경우에만 정의 하세요.) | string | - | No |
| subnet_ids | RDS 클러스터에만 추가 할 태그 입니다. | list(string) | ["subnet-0f15980c684",] | Yes |
| maintenance_window | Elasticache 유지 보수 수행시기 입니다. | string | "wed:03:00-wed:04:00" | No |
| cluster_size  | 클러스터 크기 입니다. cluster_mode_enabled 속성값이 false 인 경우에만 유효 합니다. | number | 1 | No |
| port          | 서비스 리스너 포트 입니다. | number | 6379 | No |
| instance_type | Elasticache 인스턴스 타입 입니다. | string | "cache.t2.micro" | No |
| family        | Redis family 입니다. | string | "redis6.x" | No |
| parameter     | Elasticache 구성에 필요한 설정 파라미터 입니다. | list(object) | <pre>[<br>  {<br>    name = "activerehashing"<br>    value = "no"<br>  },<br>]<pre> | No |
| engine_version | Redis 엔진 버전 입니다. | string | "6.x" | No |
| at_rest_encryption_enabled | 저장 시 데이터 암호화 활성화 여부입니다. | bool | false | No |
| transit_encryption_enabled | 데이터 전송 구간에서 데이터 암호화 활성화 여부입니다. auth_token 속성이 `true` 이면 강제로 활성화 됩니다. | bool | false | No |
| notification_topic_arn | AWS SNS 토픽의 ARN 입니다. | string | - | No |
| alarm_cpu_threshold_percent | CloudWatch 알람을 발생할 cpu threshold 비율 입니다. | number | 75 | No |
| alarm_memory_threshold_bytes | CloudWatch 알람을 발생할 memory threshold 크기 입니다. (10MB) | number | 10000000 | No |
| alarm_actions | CloudWatch 알람이 다른 상태에서 ALARM 상태로 전환될 때 실행할 작업 입니다. SNS Topic 등 작업은 ARN 을 기입 합니다. | list(string) | [aws_sns_topic.alarm.arn, ] | No |
| ok_actions    | CloudWatch 알람이 다른 상태에서 OK 상태로 전환될 때 실행할 작업 입니다. SNS Topic 등 작업은 ARN 을 기입 합니다. | list(string) | [aws_sns_topic.ok.arn, ] | No |
| apply_immediately | Elasticache 수정 사항을 즉시 적용할지 또는 유지 관리 기간 동안 적용할지 여부입니다. | bool | true | No |
| automatic_failover_enabled | 자동 failover 정책 활성화 여부 입니다. (T1/T2 인스턴스타입은 지원되지 않음) | bool | false | No |
| multi_az_enabled | 다중 가용영역 활성화 여부 입니다. cluster_mode_enabled 속성값이 `true` 이면 기본적으로 활성화 됩니다. | bool | false | No |
| availability_zones | 가용 영역 Zone 이름 입니다ㅣ. | list(string) | ["ap-northeast-2a", "ap-northeast-2b",] | No |
| auth_token | redis 암호 보호를 위한 인증 토큰으로 `transit_encryption_enabled` 속성이 `true`로 여야 합니다. 암호는 16자 이상이여야 합니다. | string | - | No |
| kms_key_id | KMS 암호화 키 (클러스터로 설정된 경우)에 대한 ARN 입니다. | string | - | No |
| replication_group_id | 클러스터 복제 그룹 아이디 입니다. 20 자리 이내의 alphanumeric 으로 입력 하여야 합니다. | string | - | No |
| snapshot_arns | Redis RDB 스냅샷 파일이 보과노딘 S3 파일의 ARN 입니다. | list(string) | ["arn:aws:s3::: my_bucket/snapshot1.rdb",] | No |
| snapshot_name | 신규 노드 그룹으로 복원할 스냅샷의 이름입니다. | string | - | No |
| snapshot_window | ElastiCache 클러스터의 Daily 스냅샷 생성을 시작하는 시간 범위(UTC 기준) 입니다. | string | "06:30-07:30" | No |
| snapshot_retention_limit | ElastiCache 가 자동으로 캐시 클러스터 스냅샷을 삭제하기 전에 보관하는 기간(Day)입니다. | number | 0 | No |
| final_snapshot_identifier | final 스냅 샷을 생성 할 때 사용되는 이름입니다. 생략하면 최종 스냅샷이 생성되지 않습니다. | string | - | No |
| cluster_mode_enabled | ElastiCache 클러스터 모드 활성화 여부입니다. | bool | false | No |
| cluster_mode_replicas_per_node_group | Redis 복제 그룹의 노드 그룹(샤드) 수입니다. | number | 0 | No |
| cloudwatch_metric_alarms_enabled | CloudWatch 메트릭 알람 발생 활성화 여부입니다. | bool | false | No |
| security_group_ids | ElastiCache 에 연결할 보안 그룹 아이디 입니다. | list(string) | ["sg-0248d0bf2b77f2",] | Yes |
| additional_tags | 추가할 태그 속성을 정의 합니다. | map(string) | { MyKey1 = "Value1" } | No |
| context | 컨텍스트 정보 입니다. 프로젝트에 관한 리소스를 생성 및 관리에 참조 되는 정보로 표준화된 네이밍 정책 및 리소스를 위한 속성 정보를 포함하며 이를 통해 데이터 소스 참조에도 활용됩니다. | object({}) | - | Yes |
|      | ____________________________________________________ |   |   |   |

__________

## Outputs

| Name | Description |
|------|-------------|
| cluster_id  | Elasticache Redis cluster ID |
| cluster_arn | Elasticache Replication Group ARN |
| cluster_enabled | Indicates if cluster mode is enabled |
| port        | Elasticache Redis listen port |
| endpoint    | Redis primary or configuration endpoint, whichever is appropriate for the given cluster mode |
| reader_endpoint | The address of the endpoint for the reader node in the replication group, if the cluster mode is disabled. |
| member_clusters | Redis cluster members |
| engine_version_actual | The running version of the cache engine |
