# 5 Tier 표준 VPC 아키텍처의 Load Balancer 배치 

앞서 구성한 5 Tier VPC 에 Public ALB, Internal ALB, Internal NLB 를 배치 합니다. 

## 아키텍처 

![vpc5tier-n1](../images/waf-vpc5tier-n1.png)

## 주요 리소스

VPC 서비스를 구성하는 주요 리소스는 다음과 같습니다.

|  Service          | Resource              |  Description |
| :-------------:   | :-------------        | :----------- |
| EC2               | ALB Public            | Internet facing 을 위한 ALB 를 Public 서브넷에 구성 합니다. |   
| EC2               | ALB WEB               | 애플리케이션 서비스 분산을 위한 Internal ALB 를 lbweb 서브넷에 구성 합니다. |   
| EC2               | NLB WAS               | 애플리케이션 서비스 분산을 위한 Internal NLB 를 lbwas 서브넷에 구성 합니다. |   
| EC2               | TargetGroup WAF       | 커스텀 웹 방화벽 애플리케이션이 배치 될 대상 그룹 "waf-tg80"을 구성 합니다. |   
| EC2               | TargetGroup WEB       | Frontend 웹 서비스용 애플리케이션이 배치 될 대상 그룹 "web-tg80"을 구성 합니다. |   
| EC2               | TargetGroup WAS       | Backend API 애플리케이션이 배치 될 대상 그룹 "was-tg8080"을 구성 합니다. |   
| EC2               | TargetGroup RDS       | AWS RDS(mysql) 서비스가 배치 될 대상 그룹 "rds-tg8080"을 구성 합니다. |   
| EC2               | TargetGroup WAS       | 애플리케이션 서비스 분산을 위한 Internal NLB 를 lbwas 서브넷에 구성 합니다. |   
| Route53           | Private Host Zone     | RDS 액세스를 위한 Private DNS 레코드를 구성 합니다. (data.<private_domain>) |   

 

## Code
- [alb/data.tf](./alb/data.tf) - 로드 밸런서를 구성 하기 위한 VPC 및 서브 네트워크를 데이터 소스로 참조 합니다. 
- [alb/alb-pub.tf](./alb/alb-pub.tf) - Public ALB 를 구성 합니다. 
- [alb/alb-web.tf](./alb/alb-web.tf) - Internal ALB 를 구성 합니다.
- [alb/alb-web.tf](./alb/nlb-was.tf) - Internal NLB 를 구성 합니다.
- [alb/providers.tf](./alb/providers.tf) - Terraform 버전과 AWS 프로바이더를 정의 합니다. 
- [alb/variables.tf](./alb/variables.tf) - vpc_cidr 변수를 정의 합니다. 


## Build

[tfmodule-aws-alb](../../docs/tfmodule-aws-alb.md) 테라폼 모듈을 통해 로드 밸런서(ALB / NLB) 리소스를 Provisioning 합니다.

```shell
git clone https://github.com/bsp-dx/terraform-hands-on.git
cd samples/waf-vpc5tier/alb

terraform init
terraform plan
terraform apply
```

ALB 구성은 [tfmodule-aws-alb](../../docs/tfmodule-aws-alb.md) 테라폼 모듈을 참고 하세요.
----------
