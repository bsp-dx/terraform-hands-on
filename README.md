# AWS 클라우드 서비스 구축 핸즈-온 
테라폼의 주요 모듈을 통해 AWS Cloud 서비스를 구성하고 애플리케이션을 인터넷 서비스로 론칭 하는 Hands On 프로젝트 입니다.

## Hands On Workflow
다음의 순서대로 가이드를 참고 하세요.

## [로컬 개발 환경 구성 - Mac OS](./docs/setup-macos.md)

## [IAM 사용자 계정 추가](./docs/aws-iam.md)

## [Domain 발급 및 ACM 구성](./docs/aws-acm.md)

## [5 Tier 표준 아키텍처를 구성](./waf-templates/5-tier-vpc-waf/guide-5tier-vpc-waf.md)
VPC 및 로드 밸런서와 같은 주요한 리소스 구성을 시작으로 애플리케이션 서비스가 가능한 서비스 Stack 을 하나씩 추가 합니다. 

## ECS Fargate 클러스터를 구성
5 Tier 표준 아키텍처 위에 ECS Fargate 클러스터를 구성하고 애플리케이션을 배포 합니다.

### [ECS Task 작업 정의](waf-templates/ecs-tasks/handson-ecs-tasks.md)

### [5 Tier ECS Fargate 구성](waf-templates/ecs-tasks/handson-ecs-fargate.md)


### 테라폼 모듈 참고

| 모듈 명 |    설명    |
| ------              | --------- |
| [tfmodule-context](./docs/tfmodule-context.md)  |	클라우드 서비스 및 리소스를 정의 하는데 표준화된 네이밍 정책과 태깅 규칙을 지원 하고, 일관성있는 데이터소스 참조 모델을 제공 합니다. |
| [tfmodule-aws-vpc](./docs/tfmodule-aws-vpc.md)  |	AWS VPC 서비스를 생성 하는 테라폼 모듈 입니다. |
| [tfmodule-aws-launchtemplate](./docs/tfmodule-aws-launchtemplate.md)  |	AWS EC2 인스턴스 론칭을 위한 시작 템플릿을 생성 하는 테라폼 모듈 입니다. |
| [tfmodule-aws-alb](./docs/tfmodule-aws-alb.md)  |	AWS (Application | Network) Load Balancer 를 생성 하는 테라폼 모듈 입니다. |
| [tfmodule-aws-autoscaling](./docs/tfmodule-aws-autoscaling.md)  |	EC2 Autoscaling 그룹을 생성하는 테라폼 모듈 입니다. |
| [tfmodule-aws-ecs](./docs/tfmodule-aws-ecs.md)  |	ECS (EC2 | Fargate) 클러스터 서비스를 생성하는 테라폼 모듈 입니다. |


## Appendix

### [EC2 Keypair 등록 참고](./docs/aws-keypair.md)

