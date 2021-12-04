# AWS 클라우드 서비스 구축 핸즈-온 
테라폼의 주요 모듈을 통해 AWS Cloud 서비스를 구성하고 애플리케이션을 인터넷 서비스로 론칭 하는 Hands On 프로젝트 입니다.

## Hands On Workflow
다음의 순서대로 가이드를 참고 하세요.

## [로컬 개발 환경 구성 - Mac OS](./docs/setup-macos.md)


## [IAM 사용자 계정 추가](./docs/aws-iam.md)

## [Domain 발급 및 ACM 구성](./docs/aws-acm.md)

## 5 Tier 표준 아키텍처를 구성 합니다.
VPC 및 로드 밸런서와 같은 주요한 리소스 구성을 시작으로 애플리케이션 서비스가 가능한 서비스 Stack 을 하나씩 추가 합니다. 

### [5 Tier VPC 구성](waf-templates/5-tier-vpc-waf/handson-vpc.md)  

#### [VPC 테라폼 모듈 참고](./docs/tfmodule-aws-vpc.md)

### [5 Tier ALB 구성](waf-templates/5-tier-vpc-waf/handson-alb.md)  

#### [ALB 테라폼 모듈 참고](./docs/tfmodule-aws-alb.md)


## ECS Fargate 클러스터를 구성
5 Tier 표준 아키텍처 위에 ECS Fargate 클러스터를 구성하고 애플리케이션을 배포 합니다.

### [ECS Task 작업 정의](waf-templates/5-tier-vpc-waf/handson-ecs-tasks.md)

### [5 Tier ECS Fargate 구성](waf-templates/5-tier-vpc-waf/handson-ecs-fargate.md)

#### [ECS 테라폼 모듈 참고](./docs/tfmodule-aws-ecs.md)


### Appendix

#### [EC2 Keypair 등록 참고](./docs/aws-keypair.md)