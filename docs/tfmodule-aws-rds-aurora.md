# tfmodule-aws-rds-aurora

AWS [Aurora RDS](https://aws.amazon.com/ko/rds/aurora) 플랫폼 서비스를 생성 하는 테라폼 모듈 입니다.

## Usage
Aurora RDS 마스터 DB 패스워드를 환경 변수로 설정 합니다.
```
exprot TF_VAR_aurora_db_password="your_rds_password"
```

```
variable "aurora_db_password" {
  type = string
}

module "aurora" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-rds-aurora-v1.0.0"

  context  = module.ctx.context
  engine                              = "aurora-postgresql"
  engine_version                      = "12.4"
  instance_type                       = "db.r5.large"
  instance_type_replica               = "db.t3.medium"
  vpc_id                              = module.vpc.vpc_id
  db_subnet_group_name                = module.vpc.database_subnet_group_name
  create_security_group               = true
  publicly_accessible                 = false
  allowed_cidr_blocks                 = toset(module.vpc.vpc_cidr_block)
  replica_count                       = 2
  iam_database_authentication_enabled = true
  username                            = "root"
  password                            = var.aurora_db_password
  apply_immediately                   = false
  skip_final_snapshot                 = true
  enabled_cloudwatch_logs_exports     = ["postgresql"]

  depends_on = [ module.vpc ]  
}

module "vpc" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-vpc-v..."
  context  = module.ctx.context
  # ... You need to define resources for vpc ...
}

module "ctx" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-context-..."
  context = {  
    # ... You need to define context variables ...
  }
}
```

### Dependencies Module

- Context 모듈은 [tfmodule-context](./tfmodule-context.md) 가이드를 참고 하세요.
- VPC 모듈은 [tfmodule-aws-vpc](./tfmodule-aws-vpc.md) 가이드를 참고 하세요.

## Example

### Aurora Postgresql

Aurora Postgresql 구성 예제 입니다.

```
module "postgresql" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-rds-aurora-v1.0.0"

  context               = module.ctx.context

  engine                = "aurora-postgresql"
  engine_version        = "11.9"
  instance_type         = "db.r5.large"
  instance_type_replica = "db.t3.medium"
  vpc_id                = module.vpc.vpc_id
  db_subnet_group_name  = module.vpc.database_subnet_group_name
  create_security_group = true
  allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks
  replica_count         = 1
  iam_database_authentication_enabled = true
  password              = var.aurora_db_password
  apply_immediately   = true
  skip_final_snapshot = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}
```

### Aurora Mysql

Aurora Mysql 구성 예제 입니다.

```
module "mysql" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-rds-aurora-v1.0.0"

  context               = module.ctx.context
  engine                = "aurora-mysql"
  engine_version        = "5.7.12"
  instance_type         = "db.r5.large"
  instance_type_replica = "db.t3.medium"
  vpc_id                = module.vpc.vpc_id
  db_subnet_group_name  = module.vpc.database_subnet_group_name
  create_security_group = true
  allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks
  replica_count         = 1
  iam_database_authentication_enabled = true
  password              = var.aurora_db_password
  apply_immediately   = true
  skip_final_snapshot = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}
```

### Serverless

Aurora Postgresql 엔진을 사용하는 Serverless 모드로 구성 되는 서비스 예제 입니다.  
Serverless 는 engine_version 을 설정하지 않습니다. scaling_configuration 속성은 engine_mode 값이 "serverless" 인 경우에만 동작 합니다.

```
module "postgresql_serverless" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-rds-aurora-v1.0.0"

  context               = module.ctx.context
  engine                = "aurora-postgresql"
  engine_mode           = "serverless"
  storage_encrypted     = true
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.database_subnets
  create_security_group = true
  allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks
  replica_count         = 0
  
  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 8
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}
```

__________

## Input Variables

| Name | Description | Type | Example | Required |
|------|-------------|------|---------|:--------:|
| allow_major_version_upgrade | 엔진 버전 변경시 주요 엔진 업그레이드 허용 여부입니다. | bool | false | No |
| allowed_cidr_blocks | 데이터베이스에 액세스 할 수있는 CIDR 블록 입니다. | list(string) | ["172.111.1.0/24"] | No |
| allowed_security_groups | 액세스를 허용할 보안 그룹 ID 입니다. | list(string) | ["sg34923474234"] | No |
| apply_immediately | DB 수정 사항을 즉시 적용할지 또는 유지 관리 기간 동안 적용할지 여부입니다. | bool | false | No |
| auto_minor_version_upgrade | 유지 관리 창에서 소규모 엔진 업그레이드를 자동으로 수행할지 여부입니다 | bool | true | No |
| backtrack_window | 대상 역 추적 시간(초)입니다. 현재는 aurora 엔진에서만 사용할 수 있습니다. 역 추적을 사용하지 않으려면이 값을 0으로 설정하십시오. 0에서 259200 (72 시간) 사이 여야합니다. | number | 0 | No |
| backup_retention_period | 백업 보관 기간 입니다. | number | 7 | No |
| ca_cert_identifier |  DB 인스턴스에 대한 CA 인증서의 식별자 입니다. | string | "rds-ca-2019" | No |
| cluster_tags | RDS 클러스터에만 추가 할 태그 입니다. | map(string) | {key1 = "value1"} | No |
| copy_tags_to_snapshot | 모든 클러스터 태그를 스냅 샷에 복사할지 여부입니다. | bool | false | No |
| create_cluster | Aurora RDS 클러스터 및 관련 리소스의 생성할지 여부입니다. | bool | true | No |
| create_monitoring_role | RDS 향상된 모니터링을 위한 IAM 역할 생성할지 여부입니다. | bool | true | No |
| create_security_group | Aurora RDS 보안 그룹의 생성할지 여부입니다. | bool | true | No |
| database_name | 클러스터 생성시 사용될 데이터베이스의 이름 입니다. 자동으로 생성 됩니다. | string | - | No |
| db_cluster_parameter_group_name | 사용할 DB 파라미터 그룹의 이름 입니다. | string | - | No |
| db_parameter_group_name | 사용할 DB 파라미터 그룹의 이름 입니다. | string | - | No |
| db_subnet_group_name | 사용할 RDS 서브넷 그룹 이름 입니다. | string | - | No |
| deletion_protection | DB 인스턴스에 삭제 보호를 활성화 할지 여부입니다. | bool | true | No |
| enable_http_endpoint | 서버리스 Aurora 데이터베이스 엔진에 대해 데이터 API를 활성화 할지 여부입니다. | bool | true | No |
| enabled_cloudwatch_logs_exports | CloudWatch 로그를 출력하는 로그 유형 입니다. ( audit, error, general, slowquery, postgresql) | list(string) | ["audit", "error", ...]) | No |
| engine | Aurora 데이터베이스 엔진 유형입니다. (aurora, aurora-mysql, aurora-postgresql) | string | "aurora" | No |
| engine_version | Aurora 데이터베이스 엔진 버전 입니다. | string | "5.6.10a" | No |
| final_snapshot_identifier_prefix | 클러스터 제거시에 최종 스냅 샷을 생성 할 때 사용할 접두어 입니다.  | string | "final" | No |
| global_cluster_identifier | aws_rds_global_cluster에 지정된 전역 클러스터 식별자 입니다. | string | - | No |
| iam_database_authentication_enabled | IAM 데이터베이스 인증을 활성화할지 여부입니다. 모든 버전과 인스턴스를 지원되는 것은 아닙니다. | bool | false | No |
| iam_role_description | IAM 역할에 대한 설명입니다. | string | - | No |
| iam_role_force_detach_policies | 역할을 제거하기 전에 역할에있는 정책을 강제로 분리할지 여부입니다. | bool | - | No |
| iam_role_managed_policy_arns | IAM 역할에 연결하여 액세스 권한을 부여할 IAM 관리형 정책 ARN 입니다. | list(string) | - | No |
| iam_role_max_session_duration | 역할에 설정할 최대 세션 기간(초) 입니다. | number | - | No |
| iam_role_path | IAM 역할 경로 입니다. | string | - | No |
| iam_role_permissions_boundary | 역할에 대한 권한 경계를 설정하는 데 사용되는 정책의 ARN 입니다. | string | - | No |
| iam_roles | RDS 클러스터에 연결할 IAM 역할의 ARN 입니다. | list(string) | [] | No |
| instance_type | 마스터 인스턴스에서 사용할 인스턴스 유형입니다. | string | - | No |
| instance_type_replica | 복제본 인스턴스에서 사용할 인스턴스 유형 (이 값이 설정되지 않은 경우 instance_type 타입과 동일한 유형을 사용합니다.) | string | - | No |
| instances_parameters | 커스텀 데이터베이스 인스턴스 파라미터 값입니다. 설정 속성은 `instance_name`, `instance_type`, `instance_promotion_tier`, `publicly_accessible` 입니다. | list(map(string)) | <pre>[<br>  {<br>    instance_type = "db.r5.2xlarge"<br>  },<br>  {<br>    instance_name = "reporting"<br>    instance_type = "db.r5.large"<br>    instance_promotion_tier = 15<br>    publicly_accessible = true<br>  }<br>]</pre> | No |
| is_primary_cluster | 기본 클러스터 생성 여부입니다. | bool | true | No |
| kms_key_id | KMS 암호화 키 (클러스터로 설정된 경우)에 대한 ARN 입니다. | string | - | No |
| monitoring_interval | Enhanced Monitoring 지표가 수집 될 때 포인트 사이의 간격(초) 입니다. | number | 0 | No |
| monitoring_role_arn | 에서 CloudWatch에 향상된 모니터링 지표를 보내기 위해 사용하는 IAM 역할입니다. | string | - | No |
| password | 마스터 DB 패스워드 입니다. | string | - | No |
| performance_insights_enabled | 성능 개선 도우미의 사용 여부입니다. | bool | false | No |
| performance_insights_kms_key_id | Performance Insights 데이터를 암호화하기위한 KMS 키의 ARN 입니다. | string | - | No |
| port | 서비스 리스닝 포트 번호입니다. (postgresql: 5432, mysql: 3306) | number | - | No |
| predefined_metric_type |  확장 할 메트릭 유형입니다. (`RDSReaderAverageCPUUtilization`, `RDSReaderAverageDatabaseConnections`) | string | "RDSReaderAverageCPUUtilization" | No |
| preferred_backup_window | DB 백업 수행 시작시간 입니다. | string | "02:00-03:00" | No |
| preferred_maintenance_window | DB 유지 보수 수행시기 입니다. | string | "sun:05:00-sun:06:00" | No |
| publicly_accessible | RDS 에 Public 아이피를 할당할지 여부입니다. | bool | false | No |
| replica_count | 읽기 전용 노드를 생성할 갯수 입니다.  | number | 1 | No |
| replica_scale_connections | 자동 확장을 시작할 평균 연결 수 임계 값입니다. (db.r4.large 타입인경우, 기본은 max_connections 의 70% 입니다.) | number | 700 | No |
| replica_scale_cpu |  자동 확장을 시작할 CPU 임계 값 입니다. | number | 70 | No |
| replica_scale_enabled | 읽기 전용 복제본에 대한 자동 확장을 활성화 할지 여부입니다. | bool | false | No |
| replica_scale_in_cooldown | scale-in 이후 추가 확장 작업을 허용 하기전 유휴 시간(초) 입니다. | number | 300 | No |
| replica_scale_min | 자동 확장이 활성화 된 경우 허용되는 최소 읽기 전용 복제본 수 입니다. | number | 2 | No |
| replica_scale_max | 자동 확장이 활성화 된 경우 허용되는 최 읽기 전용 복제본 수 입니다. | number | 0 | No |
| replica_scale_out_cooldown | scale-out 이후 추가 확장 작업을 허용 하기전 유휴 시간(초) 입니다. | number | 300 | No |
| replication_source_identifier | DB 클러스터를 읽기 전용 복제본으로 생성 할 경우 원본 DB 클러스터 또는 DB 인스턴스의 ARN 입니다. | string | - | No |
| scaling_configuration | 자동 확정을 위한 설정 입니다. engine_mode 값이 serverless 인 경우에만 유효 합니다. | map(string) | <pre>scaling_configuration = {<br>  auto_pause = true<br>  min_capacity = 1<br>  max_capacity = 4<br>  seconds_until_auto_pause = 300<br>  timeout_action = "ForceApplyCapacityChange"<br>}</pre> | No |
| security_group_description |  보안 그룹에 대한 설명입니다. | string | - | No |
| security_group_tags | 보안 그룹에 대한 추가 태그입니다. | map(string) | {key1 = "value1"} | No |
| skip_final_snapshot | DB 클러스터를 삭제하기 전에 Final DB 스냅 샷을 생성할지 여부입니다. (true 라면, 더이상 DB 스냅샷이 생성되지 않습니다.) | bool | false | No |
| snapshot_identifier |  현재 데이터베이스를 생성 할 DB 스냅샷의 식별자 입니다. | string | - | No |
| source_region |  암호화 된 복제본 DB 클러스터의 소스(원본) 리전 입니다. | string |  - | No |
| username |  마스터 DB 의 username 입니다. | string | "root" | No |
| vpc_id | VPC 아이디 입니다. | string | - | Yes |
| vpc_security_group_ids | 현재 모듈에서 생성 한 보안 그룹 외에 추가적으로 연결할 보안 그룹 입니다. | list(string) | [] | No |
| middle_name | RDS 클러스터의 중간 이름을 설정 합니다. (여러개의 RDS 클러스터를 구성 하는 경우에만 정의 하세요.) | string | - | No |
| context | 컨텍스트 정보 입니다. 프로젝트에 관한 리소스를 생성 및 관리에 참조 되는 정보로 표준화된 네이밍 정책 및 리소스를 위한 속성 정보를 포함하며 이를 통해 데이터 소스 참조에도 활용됩니다. | object({}) | - | Yes |
|      | ____________________________________________________ |   |   |   |

__________

## Outputs

| Name | Description |
|------|-------------|
| enhanced_monitoring_iam_role_arn | The Amazon Resource Name (ARN) specifying the enhanced monitoring role |
| enhanced_monitoring_iam_role_name | The name of the enhanced monitoring role |
| enhanced_monitoring_iam_role_unique_id | Stable and unique string identifying the enhanced monitoring role |
| rds_cluster_arn | The ID of the cluster |
| rds_cluster_database_name | Name for an automatically created database on cluster creation |
| rds_cluster_endpoint | The cluster endpoint |
| rds_cluster_engine_version | The cluster engine version |
| rds_cluster_hosted_zone_id | Route53 hosted zone id of the created cluster |
| rds_cluster_id | The ID of the cluster |
| rds_cluster_instance_dbi_resource_ids | A list of all the region-unique, immutable identifiers for the DB instances |
| rds_cluster_instance_endpoints | A list of all cluster instance endpoints |
| rds_cluster_instance_ids | A list of all cluster instance ids |
| rds_cluster_master_password | The master password |
| rds_cluster_master_username | The master username |
| rds_cluster_port | The port |
| rds_cluster_reader_endpoint | The cluster reader endpoint |
| rds_cluster_resource_id | The Resource ID of the cluster |
| security_group_id | The security group ID of the cluster |


## Reference

원본 출처는 Apr 19, 2021 버전의 [terraform-aws-rds-aurora](https://github.com/terraform-aws-modules/terraform-aws-rds-aurora)
입니다. 참고 하세요. 
