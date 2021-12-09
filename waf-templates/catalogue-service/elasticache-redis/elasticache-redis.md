# Elasticache Redis

AWS [Elasticache-Redis](https://docs.aws.amazon.com/ko_kr/AmazonElastiCache/latest/red-ug/WhatIs.html)  서비스를 구성 합니다.

## 데이터 소스 참조

Elasticache Redis 서비스를 구성 하려면, 먼저 Redis 가 배치될 VPC 와 서브넷이 준비 되어야 합니다.

VPC 의 네트워크 중 Elasticache Redis 인스턴스에 액세스 할 수 있는 영역을 WAS 애픝리케이션이 배치 되어 있는 서브넷 영역으로 제한 하기 위해 [data.tf](./data.tf) 데이터 소스를 식별하여 정의 합니다. 
 
| Resource | Name | Description | Example | 
| ---- | ----------- | ------- | ------- |
| aws_vpc     | this  | VPC 데이터 소스를 참조 합니다. | data.aws_vpc.this.id |
| aws_subnets | was   | WAS 서브넷 데이터 소스를 참조 합니다. | data.aws_subnets.was.ids | 
| aws_subnet  | was   | WAS 서브넷 식별을 위한 데이터 소스를 참조 합니다. | data.aws_subnet.was | 


```
data "aws_subnets" "was" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${module.ctx.name_prefix}-was*"]
  }
}

data "aws_subnet" "was" {
  for_each = toset(data.aws_subnets.was.ids)
  id       = each.value
}

```


## Build

VPC 및 Elasticache Redis 를 위한 네트워크가 사전에 구성 되어 있어야 데이터 소스로 참조할 수 있습니다.

아직 VPC 가 준비되지 않았다면 [VPC](../../../docs/tfmodule-aws-vpc.md) 가이드를 참고하여 구성 하세요.


### Checkout

git clone 명령으로 프로젝트를 체크 아웃 합니다.

```
git clone https://github.com/bsp-dx/terraform-hands-on.git
```

### 프로젝트 환경 변수 설정

- WAF_PROJECT_HOME 프로젝트 홈 경로를 위한 환경 변수를 설정 합니다.

```
export WAF_PROJECT_HOME=$(pwd -P)/terraform-hands-on/waf-templates/catalogue-service/elasticache-redis
```

### Build Elasticache Redis

```shell
cd ${WAF_PROJECT_HOME}

terraform init
terraform plan
terraform apply
```

- [context/main.tf](./context/main.tf) 컨텍스트 정보를 참조 합니다.  
  기존에 구성된 프로젝트 정보를 기반으로 context 정보를 정의 하여야 합니다.
- [main.tf](./main.tf) 코드를 메인으로 Elasticache Redis 서비스를 생성합니다.


## Destroy

Elasticache Redis 를 삭제 합니다.

```shell
cd ${WAF_PROJECT_HOME}

terraform destroy
```

## References

Elasticache Redis 서비스 구성에 필요한 테라폼 자동화 모듈은 다음과 같습니다.

- [Context](../../../docs/tfmodule-context.md) 테라폼 모듈 가이드
- [VPC](../../../docs/tfmodule-aws-vpc.md) 테라폼 모듈 가이드
- [Elasticache Redis](../../../docs/tfmodule-aws-elasticache-redis.md) 테라폼 모듈 가이드
  