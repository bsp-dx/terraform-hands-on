# 5 Tier 표준 VPC 아키텍처 구성

5 Tier VPC 표준 아키텍처로 가용영역 및 3rd-party WAF, WEB, WAS, RDS, ElastiCache 이중화로 설계된 표준 VPC 아키텍처를 구성 합니다. 

## 아키텍처 

![vpc5tier-n1](../images/waf-vpc5tier-n1.png)

## 주요 리소스

VPC 서비스를 구성하는 주요 리소스는 다음과 같습니다.

|  Service          | Resource              |  Description |
| :-------------:   | :-------------        | :----------- |
| VPC               | VPC                   | AWS VPC(프라이빗 클라우드)서비스를 구성 합니다. |   
| VPC               | Internet Gateway      | 인터넷 사용자(애플리케이션) vs VPC 내의 리소스(ELB, EC2, ...)간 통신을 위한 Internet Gateway 를 구성 합니다. |   
| VPC               | Nat Gateway           | VPC 내의 리소스(EC2, ..)에서 외부 인터넷 자원(github, docker.hub,...) 을 액세스 하기 위한 NAT 게이트웨이를 구성 합니다. |   
| VPC               | EIP                   | NAT 게이트웨이가 사용하는 EIP(Elastic IP) 를 구성 합니다.  |   
| VPC               | Public Subnet         | VPC 내의 Public 서브 네트워크를 구성 합니다. 인터넷 사용자(애플리케이션)과 직접적인 액세스가 가능 합니다. |   
| VPC               | Private Subnet        | Private 서브 네트워크를 구성 합니다. |   
| VPC               | WAF Private Subnet    | 커스텀 웹 방화벽 애플리케이션 이 배치 될 Private 서브 네트워크를 구성 합니다. |   
| VPC               | WEB Private Subnet    | UI를 담당하는 WEB 애플리케이션 서비스가 배치 될 Private 서브 네트워크를 구성 합니다. |   
| VPC               | API Private Subnet    | Backend API 애플리케이션 서비스가 배치 될 Private 서브 네트워크를 구성 합니다. |   
| VPC               | lbweb Private Subnet  | UI WEB 애플리케이션을 위한 로드 밸런서가 사용 할 Private 서브 네트워크를 구성 합니다. |   
| VPC               | lbwas Private Subnet  | Backend API 애플리케이션을 위한 로드 밸런서가 사용 할 Private 서브 네트워크를 구성 합니다. |   
| VPC               | Private Subnet WAF    | 커스텀 웹 방화벽 애플리케이션 이 배치될 Private 서브 네트워크를 구성 합니다. |   
| VPC               | Routing Tables        | VPC 내의 public 및 private 서브 네트워크의 서로 다른 IP 대역들에 대해 액세스 연결을 위한 라우팅 경로를 설정 합니다. |   
| VPC               | Security Group        | VPC 를 위한 기본 security_group 을 구성 합니다. |

* web 및 api 를 위한 별도의 로드 밸런서용 Sub-network 를 두는 이유는 한정된 Private-IP 로 인해 로드 밸런서가 부하에 대응하여 확장되지 못하는 위험을 사전에 방지하기 위함 입니다.
 


| VPC               | ALB                   | internet facing 을 위한 ALB 를 구성 합니다. |   
| VPC               | ALB                   | 애플리케이션 서비스 분산을 위한 Internal ALB 를 구성 합니다. |   
| VPC               | NLB                   | 애플리케이션 서비스 분산을 위한 Internal NLB 를 구성 합니다. |   

## Code
- [vpc/main.tf](./vpc/main.tf) - tfmodule-aws-vpc 모듈을 임포트 하여 VPC 를 구성 합니다. 
- [vpc/providers.tf](./vpc/providers.tf) - Terraform 버전과 AWS 프로바이더를 정의 합니다. 
- [vpc/variables.tf](./vpc/variables.tf) - vpc_cidr 변수를 정의 합니다. 
- [vpc/terraform.tfvars](./vpc/variables.tf) - vpc_cidr 변수값을 정의 합니다.


## Build

[tfmodule-aws-vpc](../../docs/tfmodule-aws-vpc.md) 테라폼 모듈을 통해 VPC 아키텍처를 Provisioning 합니다.

```shell
git clone https://github.com/bsp-dx/terraform-hands-on.git
cd samples/waf-vpc5tier/vpc

terraform init
terraform plan
terraform apply
```

## Check

AWS 관리 콘솔에 로그인 하거나 또는 AWS CLI 를 통해 구성된 리소스를 확인 할 수 있습니다.

```
# VPC 확인 
aws ec2 describe-vpcs --filters 'Name=tag:Name,Values=<VPC_NAME>*'

# Subnets 확인  
aws ec2 describe-subnets --filters 'Name=tag:Name,Values=<VPC_NAME>*' --query 'Subnets[].Tags[?Key==`Name`].Value[]' --output=table
```


VPC 구성은 [tfmodule-aws-vpc](../../docs/tfmodule-aws-vpc.md) 테라폼 모듈을 참고 하세요.
----------
