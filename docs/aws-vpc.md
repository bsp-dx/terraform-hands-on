# VPC

AWS [VPC](https://docs.aws.amazon.com/vpc/index.html) 서비스를 테라폼을 통해 자동화 구성 합니다.

## 주요 리소스

VPC 서비스를 구성하는 테라폼 모듈로 다음의 주요 리소스를 구성할 수 있습니다.

![VPC](images/aws-3tier-vpc.png)

|  Service          | Resource              |  Description |
| :-------------:   | :-------------        | :----------- |
| VPC               | VPC                   | AWS VPC 서비스를 구성 합니다. |   
| VPC               | Internet Gateway      | 인터넷 사용자(애플리케이션) vs VPC 내의 리소스(ELB, EC2, ...)간 통신을 위한 Internet Gateway 를 구성 합니다. |   
| VPC               | Nat Gateway           | VPC 내의 리소스(EC2, ..)에서 외부 인터넷 자원(github, docker.hub,...) 을 액세스 하기 위한 NAT 게이트웨이를 구성 합니다. |   
| VPC               | EIP                   | NAT 게이트웨이가 사용하는 EIP(Elastic IP) 를 구성 합니다.  |   
| VPC               | Public Subnet         | VPC 내의 Public 서브 네트워크를 구성 합니다. 인터넷 사용자(애플리케이션)과 직접적인 액세스가 가능 합니다. |   
| VPC               | Private Subnet        | VPC 내의 Private 서브 네트워크를 구성 합니다. |   
| VPC               | Database Subnet       | VPC 내의 AWS RDS 등 Database 서브 네트워크를 구성 합니다. |   
| VPC               | Routing Tables        | VPC 내의 public 및 private 서브 네트워크의 서로 다른 IP 대역들에 대해 액세스 연결을 위한 라우팅 경로를 설정 합니다. |   
| VPC               | Security Group        | VPC 를 위한 기본 security_group 을 구성 합니다. |   
| VPC               | Network ACL           | NACL 방화벽 정책을 구성 합니다. |   
| Route 53          | Private Host Zone     | 프라이빗 도메인을 구성 합니다. |   

## Build

Terraform 을 통해 AWS 클라우드에 VPC 서비스를 생성(Provisioning) 합니다.

```shell
git clone https://github.com/bsp-dx/terraform-hands-on.git
cd terraform-hands-on/vpc/completed

terraform init
terraform plan
terraform apply
```

## Check

AWS 관리 콘솔 또는 AWS CLI 를 통해 구성된 리소스를 확인 할 수 있습니다.

```
# VPC 확인 
aws ec2 describe-vpcs --filters 'Name=tag:Name,Values=mydemo*'

# Subnets 확인 (pub, pri, web, api, data 에 대해 각각 2개의 az 으로 구성되므로 총 10개의 subnet 이 확인 됩니다.)  
aws ec2 describe-subnets --filters 'Name=tag:Name,Values=mydemo*' --query 'Subnets[].Tags[?Key==`Name`].Value[]' --output=table
```

- AWS 관리 콘솔을 통해 확인
  ![vpc-subnets](images/fireshot-20211117-004.png)

## Terraform VPC 모듈의 이해

'tfmodule-aws-vpc' 표준화된 모듈을 통해 VPC 를 구현 합니다.

- VPC 모듈의 정의

테라폼 모듈은 module "{모듈 이름}" 블럭으로 정의 합니다.

아래 코드는 "vpc" 라는 테라폼 모듈을 정의 하는 예시 입니다.

```
module "vpc" {

  /* 테라폼 자동화 모듈인 'tfmodule-aws-vpc' 을 참조 합니다. */
  source = "../module/tfmodule-aws-vpc/"
  
  /* DxBuiler 를 통한 표준화된 클라우드 정책 중 Resource 네이밍 정책과 Tags 속성 정책이 context 정보를 기준으로 설정 됩니다. */
  context = var.context

  ...
}
```

## VPC 모듈의 주요 입력 변수

<table>
<thead>
    <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Type</th>
        <th>Default</th>
        <th>Required</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>region</td>
        <td>AWS 리전 약어를 입력 합니다.</td>
        <td>string</td>
        <td>an2</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>env</td>
        <td>develop, stage, production 과 같은 런-타임 환경 약어를 입력 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>team</td>
        <td>클라우드 관리 주체인 팀 이름을 입력 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>owner</td>
        <td>프로젝트 Owner를 입력합니다. 이메일, 어카운트 또는 관리 부서가 될 수 있습니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>create_vpc</td>
        <td>프로비저닝을 통해 정의된 VPC를 생성 합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
    <tr>
        <td>name</td>
        <td>VPC 대표 이름을 설정 합니다. 대게 서비스명 또는 프로젝트명이 올 수 있습니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>cidr</td>
        <td>VPC 네트워크의 CIDR 네트워크 대역을 정의 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>azs</td>
        <td>availability zones ID를 입력 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>public_subnets</td>
        <td>public subnet을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>public_subnet_names</td>
        <td>public subnet 이름을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>public_subnet_suffix</td>
        <td>public subnet 대표 이름을 정의 합니다. 이 값은 public 서브넷을 위한 라우팅 테이블의 리소스 이름을 대표 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>private_subnets</td>
        <td>private subnet을 정의 합니다. 특히 NAT를 위한 라우팅 테이블은 private subnet 을 기준으로 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>private_subnet_names</td>
        <td>private subnet 이름을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>private_subnet_suffix</td>
        <td>private subnet 대표 이름을 정의 합니다. 이 값은 private 서브넷을 위한 라우팅 테이블의 리소스 이름을 대표 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>enable_nat_gateway</td>
        <td>private subnet 에 대해 NAT GW를 생성하는 경우 true 로 설정 합니다. private_subnet 에 대한 설정이 필요 합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>single_nat_gateway</td>
        <td>하나의 NAT 게이트웨이만 생성 합니다. (한개의 NAT Gateway 로 모든 private subnet의 액세스를 지원 합니다.)</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>one_nat_gateway_per_az</td>
        <td>availability zone 갯수만큼 NAT 게이트웨이를 생성 합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>database_subnets</td>
        <td>database subnet을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>database_subnet_names</td>
        <td>database subnet 이름을 정의 합니다.</td>
        <td>list</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>database_subnet_suffix</td>
        <td>database subnet 대표 이름을 정의 합니다.</td>
        <td>string</td>
        <td>null</td>
        <td>no</td>
    </tr>
    <tr>
        <td>create_database_subnet_route_table</td>
        <td>데이터베이스에 대한 별도의 라우팅 테이블을 생성해야하는지 여부를 정의합니다. (DBMS 패치를 인터넷으로부터 직접 패치하는 경우 설정 할 수 있음)</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
    <tr>
        <td>create_database_nat_gateway_route</td>
        <td>데이터베이스 서브넷 전용 NAT Gateway를 생성 여부를 정의합니다.</td>
        <td>bool</td>
        <td>false</td>
        <td>no</td>
    </tr>
</tbody>
</table>

## VPC 모듈의 사용 예시

- VPC 의 CIDR 블럭을 "172.100.0.0/16" 으로 정의 
- 서울 리전 대상으로 고 가용성을 위해 availability zone 을 3개("apne2-az1, apne2-az2, apne2-az3") 로 정의 
- public 서브넷을 pub-a1, pub-b1, pub-c1 으로 정의 하고 CIDR 을 172.100.[1-3].0/24 으로 정의 
- private 서브넷을 internal-a1, internal-b1, internal-c1 으로 정의 하고 CIDR 을 172.100.[31-33].0/24 으로 정의

만약 고객이 위와 같은 VPC 서비스를 구성해 달라는 요청을 한다면 아래와 같이 쉽게 구성을 할 수 있습니다.

```
module "vpc" {

  source = "../module/tfmodule-aws-vpc/"
  context = var.context

  cidr    = "172.100.0.0/16"

  # availability zone 의 정의 
  azs                  = ["apne2-az1", "apne2-az2", "apne2-az3"]

  public_subnets       = ["172.100.1.0/24", "172.100.2.0/24", "172.100.3.0/24"]
  public_subnet_names  = ["pub-a1", "pub-b1", "pub-c1"]

  private_subnets = ["172.100.31.0/24", "172.100.32.0/24", "172.100.33.0/24"]
  private_subnet_names = [ "internal-a1", "internal-b1", "internal-c1"]

}
```