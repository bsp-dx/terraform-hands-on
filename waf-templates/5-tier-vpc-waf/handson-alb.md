# 5 Tier 표준 VPC 아키텍처의 Load Balancer 배치 

5 Tier VPC 를 위한 Public ALB, Internal ALB, Internal NLB 를 배치 합니다. 

## 아키텍처 

![vpc5tier-n1](../../samples/images/waf-vpc5tier-n1.png)

### 서비스 시나리오는 아래와 같습니다.  
외부 클라이언트의 요청은 Domain - Route 53 을 통해 IGW 으로 진입 합니다. 
1. Public ALB 는 외부 클라이언트의 요청을 Security Subnet의 TargetGroup WAF 으로 전달 합니다.
2. TargetGroup WAF 에 배치된 3rd-party 방화벽 애플리케이션은 트래픽 감사를 하고, 정상이라면 UI Web 서비스로 전달 합니다.
3. UI Web 서비스 앞단에 배치된 Internal ALB 인 WEB-ALB 를 통해 TargetGroup WEB 으로 전달 합니다.
4. TargetGroup WEB 에 배치된 UI 용 애플리케이션은 Backend API 를 호출 합니다.
5. Backend API 전면에 배치된 Internal NLB 인 WAS-NLB 를 통해 서비스 port 에 대응 하는 endpoint 로 라우팅 합니다.  
 * WEB 애플리케이션 서비스 또는 RDS 데이터 베이스

## 주요 리소스

ALB 를 구성하는 주요 리소스는 다음과 같습니다.

|  Service          | Resource              |  Description |
| :-------------:   | :-------------        | :----------- |
| EC2               | ALB Public            | Internet facing 을 위한 ALB 를 Public 서브넷에 구성 합니다. |
| EC2               | ALB WEB               | 애플리케이션 서비스 분산을 위한 Internal ALB 를 lbweb 서브넷에 구성 합니다. |
| EC2               | NLB WAS               | 애플리케이션 서비스 분산을 위한 Internal NLB 를 lbwas 서브넷에 구성 합니다. |
| EC2               | TargetGroup WAF       | 커스텀 웹 방화벽 애플리케이션이 배치 될 대상 그룹 "waf-tg80"을 구성 합니다. |
| EC2               | TargetGroup WEB       | Frontend 웹 서비스용 애플리케이션이 배치 될 대상 그룹 "web-tg80"을 구성 합니다. |
| EC2               | TargetGroup WAS       | Backend API 애플리케이션이 배치 될 대상 그룹 "was-tg8080"을 구성 합니다. |
| EC2               | TargetGroup RDS       | AWS RDS(mysql) 서비스가 배치 될 대상 그룹 "rds-tg8080"을 구성 합니다. |
| Route53           | Public Host Zone      | nginx 애플리케이션 액세스를 위한 Public DNS 레코드를 구성 합니다. (nginx.<domain>) |

그 외에도 로드밸런서 Listener 와 Routing Rule, 대상 그룹의 Health check 매트릭 등이 구성 됩니다. 


## Code
- [alb-waf/main.tf](alb-waf/main.tf) - Public ALB 구성 정보를 정의 합니다.
- [alb-waf/data.tf](alb-waf/data.tf) - Public ALB 를 구성 하기 위한 데이터 소스를 정의 합니다.
- [alb-web/main.tf](alb-web/main.tf) - Internal ALB 구성 정보를 정의 합니다.
- [alb-web/data.tf](alb-web/data.tf) - Internal ALB 를 구성 하기 위한 데이터 소스를 정의 합니다.
- [nlb-was/main.tf](nlb-was/main.tf) - Internal NLB 구성 정보를 정의 합니다.
- [nlb-was/data.tf](nlb-was/data.tf) - Internal NLB 를 구성 하기 위한 데이터 소스를 정의 합니다.


## Public ALB
Public ALB 의 이름은 waf 라로 정의 하고, public 서브넷과 연결 되어야 합니다.  
Public ALB 전요 보안 그룹을 생성 합니다.  
유입되는 정상적인 트래픽은 web-80tg 대상 그룹으로 전달 합니다.

- Context 모듈(module.ctx)을 통해 네이밍 규칙에 기반한 VPC, Subent, ACM 대해 데이터 소스를 참조 합니다.
- [data.tf](alb-waf/data.tf) : WAF Public ALB 가 참조하는 데이터 소스 
- [main.tf](alb-waf/main.tf) : WAF Public ALB 리소스 생성


### Build Public ALB

```shell
git clone https://github.com/bsp-dx/terraform-hands-on.git
cd terraform-hands-on/waf-templates/5-tier-vpc-waf/alb-waf

terraform init
terraform plan
terraform apply
```


## Internal ALB
Internal ALB 의 이름은 web 으로 정의 하고, lbweb 서브넷과 연결 되어야 합니다.  
유입되는 네트워크 트래픽은 web-80tg 대상 그룹으로 전달 합니다.
Internal ALB 전용 보안 그룹을 생성 합니다. 

- Context 모듈(module.ctx)을 통해 네이밍 규칙에 기반한 VPC, Subent, Security Group 에 대해 데이터 소스를 참조 합니다.
- [data.tf](alb-web/data.tf) : WEB Internal ALB 가 참조하는 데이터 소스
- [main.tf](alb-web/main.tf) : WEB Internal ALB 리소스 생성


### Build Internal ALB

```shell
git clone https://github.com/bsp-dx/terraform-hands-on.git
cd terraform-hands-on/waf-templates/5-tier-vpc-waf/alb-web

terraform init
terraform plan
terraform apply
```


## Internal NLB
Internal NLB 의 이름은 was 로 정의 하고, lbwas 서브넷과 연결 되어야 합니다.  
네트워크 트래픽 중 8080 포트는로 유입되는 데이터는 was-8080tg 대상 그룹으로, 3306 포트로 유입되는 데이터는 rds-3306 대상 그룹으로 각각 전달 합니다.

- Context 모듈(module.ctx)을 통해 네이밍 규칙에 기반한 VPC, Subent, Security Group 에 대해 데이터 소스를 참조 합니다.
- [data.tf](nlb-was/data.tf) : WAS Internal NLB 가 참조하는 데이터 소스
- [main.tf](nlb-was/main.tf) : WAS Internal NLB 가 참조하는 데이터 소스

### Build Internal NLB

```shell
git clone https://github.com/bsp-dx/terraform-hands-on.git
cd terraform-hands-on/waf-templates/5-tier-vpc-waf/nlb-was

terraform init
terraform plan
terraform apply
```


ALB 구성은 [tfmodule-aws-alb](../../docs/tfmodule-aws-alb.md) 테라폼 모듈을 참고 하세요.
----------
