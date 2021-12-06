# AWS 클라우드 서비스 구축 핸즈-온 
테라폼의 주요 모듈을 통해 AWS Cloud 서비스를 구성하고 애플리케이션을 인터넷 서비스로 론칭 하는 Hands On 프로젝트 입니다.

# Table of Contents

## [로컬 개발 환경 구성 - Mac OS](./docs/setup-macos.md)

## [IAM 사용자 계정 추가](./docs/aws-iam.md)

## [Domain 발급 및 ACM 구성](./docs/aws-acm.md)

## [5 Tier VPC 표준 아키텍처를 구성](./waf-templates/5-tier-vpc-waf/guide-5tier-vpc-waf.md)
VPC 및 로드 밸런서와 같은 주요한 리소스 구성을 시작으로 애플리케이션 서비스가 가능한 서비스 Stack 을 하나씩 추가 합니다. 

## [5 Tier ECS Fargate 표준 아키텍처 구성](./waf-templates/5-tier-ecs-fargate/guide-5-tier-ecs-fargate.md)
5 Tier 표준 아키텍처 위에 ECS Fargate 클러스터를 구성합니다.

- [Deploy nginx-service to ECS Fargate](./waf-templates/5-tier-ecs-fargate/deploy-service-to-ecs.md)
ECS Fargate 클러스터에 사용자 애플리케이션 서비스(nginx-service)를 배포 합니다.
ECS 서비스를 배포 하려면 먼저 [ECS Task 작업 정의](./#ecs-task-작업-정의)가 구성 되어 있어야 합니다.

__________

## Catalogue Service 구성
WAF 표준 아키텍처 구성 이후 고객의 요청에 대응하여 AWS 서비스를 구성 하는 경우에 활용 하는 템플릿 입니다.

### [ECS Task 작업 정의](waf-templates/catalogue-service/ecs-tasks/ecs-tasks.md)
ECS 클러스터에 서비스를 론칭 하기 위해선 사전에 먼저 ECS 작업 정의를 해야 합니다.    
생성된 ECS 작업들은 Region 에서 관리 되며 여러 서비스가 이를 활용 할 수 있습니다.

### [Aurora RDS 구성](./waf-templates/catalogue-service/aurora-postgresql/aurora-postgresql.md)


__________

## 테라폼 모듈 참고

| 모듈 명 |    설명    |
| ------              | --------- |
| [tfmodule-context](./docs/tfmodule-context.md)  |	클라우드 서비스 및 리소스를 정의 하는데 표준화된 네이밍 정책과 태깅 규칙을 지원 하고, 일관성있는 데이터소스 참조 모델을 제공 합니다. |
| [tfmodule-aws-vpc](./docs/tfmodule-aws-vpc.md)  |	AWS VPC 서비스를 생성 하는 테라폼 모듈 입니다. |
| [tfmodule-aws-launchtemplate](./docs/tfmodule-aws-launchtemplate.md)  |	AWS EC2 인스턴스 론칭을 위한 시작 템플릿을 생성 하는 테라폼 모듈 입니다. |
| [tfmodule-aws-alb](./docs/tfmodule-aws-alb.md)  |	AWS (Application | Network) Load Balancer 를 생성 하는 테라폼 모듈 입니다. |
| [tfmodule-aws-autoscaling](./docs/tfmodule-aws-autoscaling.md)  |	EC2 Autoscaling 그룹을 생성하는 테라폼 모듈 입니다. |
| [tfmodule-aws-ecs](./docs/tfmodule-aws-ecs.md)  |	ECS (EC2 | Fargate) 클러스터 서비스를 생성하는 테라폼 모듈 입니다. |
| [tfmodule-aws-rds-aurora](./docs/tfmodule-aws-rds-aurora.md)  |	AWS [Aurora RDS](https://aws.amazon.com/ko/rds/aurora) 플랫폼 서비스를 생성 하는 테라폼 모듈 입니다. |


__________

## Appendix

### [EC2 Keypair 등록 참고](./docs/aws-keypair.md)

