## Aurora RDS

[Aurora RDS](https://aws.amazon.com/ko/rds/aurora) 서비스를 구성 합니다. 

Amazon Aurora 는 클라우드용으로 구축된 MySQL 및 PostgreSQL 호환의 관계형 데이터베이스 엔진을 제공 합니다.


## 데이터 소스 참조

Aurora RDS 서비스를 구성 하려면, 먼저 DB 인스턴스가 배치될 VPC 와 서브넷이 준비 되어야 합니다.

- Aurora RDS 서비스 구성을 위한 데이터 소스 참조 : [data.tf](data.tf)

| Resource | Name | Description | Example | 
| ---- | ----------- | ------- | ------- |
| aws_vpc     | this  | VPC 데이터 소스를 참조 합니다. | data.aws_vpc.this.id |
| aws_subnets | was   | WAS 서브넷 데이터 소스를 참조 합니다. | data.aws_subnets.was.ids | 
| aws_subnet  | was   | WAS 서브넷 CICD 식별을 위한 데이터 소스를 참조 합니다. | data.aws_subnet.was | 

- VPC 의 WAS 애픝리케이션이 배치되어 있는 서브 네트워크 영역만 DB 인스턴스에 액세스 할 수 있도록 허용 하였습니다.

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

VPC 및 database 를 위한 서브넷이 구성 되어 있어야 하며, 데이터 소스로 참조할 수 있어야 합니다.

### Checkout

git clone 명령으로 프로젝트를 체크 아웃 합니다.

```
git clone https://github.com/bsp-dx/terraform-hands-on.git
```

### 프로젝트 환경 변수 설정

WAF_PROJECT_HOME 프로젝트 홈 경로를 위한 환경 변수를 설정 합니다.

```
export WAF_PROJECT_HOME=$(pwd -P)/terraform-hands-on/waf-templates/catalogue-service/aurora-postgresql
```

### Build Aurora RDS

```shell
cd ${WAF_PROJECT_HOME}

terraform init
terraform plan
terraform apply
```

- [context/main.tf](./context/main.tf) 컨텍스트 정보를 참조 합니다.
- [main.tf](./main.tf) 코드를 메인으로 Aurora RDS 서비스를 생성합니다.


## Destroy

Aurora RDS 를 삭제 합니다.

```shell
cd ${WAF_PROJECT_HOME}

terraform destroy
```

## References
Aurora RDS 서비스 구성에 필요한 테라폼 자동화 모듈은 다음과 같습니다.

- [Context](../../../docs/tfmodule-context.md) 테라폼 모듈 가이드
- [VPC](../../../docs/tfmodule-aws-vpc.md) 테라폼 모듈 가이드
- [Aurora RDS](../../../docs/tfmodule-aws-rds-aurora.md) 테라폼 모듈 가이드
  