# tfmodule-aws-alb

AWS (Application | Network) Load Balancer 를 생성 하는 테라폼 모듈 입니다.

## Usage

```
module "alb" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-alb-v1.0.0"

  context  = module.ctx.context
  lb_name = "pub"
  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = toset(module.vpc.public_subnets)
  security_groups = [ module.vpc.default_security_group_id ]

  http_tcp_listeners = [ {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },]
  
  depends_on = [module.vpc]
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

## ALB Sample
```
module "alb" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-aws-alb"

  context  = module.ctx.context
  lb_name = "pub"
  load_balancer_type = "application"

  vpc_id          = "${vpc_id}"
  subnets         = [ "${subnet_id}" ]
  security_groups = [ "${security_group_id}" ]
  # ...
}
```


## NLB Sample
```
module "nlb" {
  source = "git::https://github.com/bsp-dx/eks-apps-handson//module/tfmodule-aws-alb"

  context  = module.ctx.context
  lb_name = "was"
  load_balancer_type = "network"

  vpc_id          = "${vpc_id}"
  subnets         = [ "${subnet_id}" ]
  # ...
}
```

## Target Group Sample

target_groups 속성 값의 설정을 통해 하나 이상의 대상 그룹을 정의 할 수 있습니다.  
target_group 의 하위 구성 요소로 health_check, targets 인스턴스를 선택적으로 구성 가능 합니다.

```
  target_groups = [
    {
      name                 = "web-tg80"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
    },
    {
      name                 = "was-tg8080"
      backend_protocol     = "HTTP"
      protocol_version     = "HTTP1"
      backend_port         = 8080
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        port                = "traffic-port"
        path                = "/health"
        interval            = 30
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-302"
      }
      targets = {
        order1_ec2 = {
          target_id = data.aws_instance.order1_ec2.id
          port      = 8080
        },
        order2_ec2 = {
          target_id = data.aws_instance.order2_ec2.id
          port      = 8080
        }
      }            
    },
    {
      name                 = "postgres-tg5432"
      backend_protocol     = "TCP"
      backend_port         = 5432
      target_type          = "ip"
    },
  ]
```

## HTTP Listener Sample

로드 밸런서에 서비스 포트를 생성 합니다. 서비스 포트에 알맞은 타겟 그룹으로 보내거나 적절한 Response 응답을 정의 할 수 있습니다.

```
  [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
    {
      port        = 81
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    {
      port        = 82
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    },
  ]
```

## HTTP Listener Rules Sample

http_tcp_listener 리스너에 대한 라우팅 룰을 설정 합니다.

```
  [
    {
      http_tcp_listener_index = 0
      priority                = 3
      actions = [{
        type         = "fixed-response"
        content_type = "text/plain"
        status_code  = 200
        message_body = "This is a fixed response"
      }]
  
      conditions = [{
        http_headers = [{
          http_header_name = "x-Gimme-Fixed-Response"
          values           = ["yes", "please", "right now"]
        }]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 5000
      actions = [{
        type        = "redirect"
        status_code = "HTTP_302"
        host        = "www.youtube.com"
        path        = "/watch"
        query       = "v=dQw4w9WgXcQ"
        protocol    = "HTTPS"
      }]
  
      conditions = [{
        query_strings = [{
          key   = "video"
          value = "random"
        }]
      }]
    },
  ]
```

## HTTPS Listener Sample

로드 밸런서에 HTTPS 프로토콜 전용 서비스 포트를 생성 합니다. 서비스 포트에 알맞은 타겟 그룹으로 보내거나 적절한 Response 응답을 정의 할 수 있습니다.

```
  [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "acm_certificate_arn"
      target_group_index = 0
    },
  ]
```


## HTTPS Listener Rules Sample

로드 밸런서에 HTTPS 리스너를 위한 라우팅 룰을 정의 합니다.

```
  [
    {
      https_listener_index = 0
      priority             = 1
      actions = [{
        type         = "fixed-response"
        content_type = "text/plain"
        status_code  = 200
        message_body = "This is a fixed response"
      }]
    },
    {
      https_listener_index = 0
      priority             = 2
      actions = [{
          type               = "forward"
          target_group_index = 0
        }]
      conditions = [{
        path_patterns = ["/*"]
      }]
    },
    {
      https_listener_index = 0
      priority             = 3
      actions = [{
          type = "forward",
          target_group_index = 0
        }]
      conditions = [{
        host_headers = [ "www.your-public-domain", "api.your-public-domain"  ]
      }]
    },
  ]
```

## Input Variables

| Name | Description | Type | Example | Required |
|------|-------------|------|---------|:--------:|
| create_lb | Load Balancer 생성 여부입니다. | bool | true | No |
| lb_name | Load Balancer 리소스 이름을 정의 합니다. | string | - | No |
| drop_invalid_header_fields | ALB 에서 잘못된 헤더 필드가 삭제되었는지 여부입니다. | bool | false | No |
| enable_deletion_protection | AWS API를 통해 로드 밸런서 삭제를 할 수 없도록 합니다. Terraform 등의 툴에 의해 로드 밸런서가 삭제하는 것을 방지할 수 있습니다. | bool | false | No |
| enable_http2 | ALB 에 HTTP/2 프로토콜 지원을 활성화 합니다. | bool | true | No |
| enable_cross_zone_load_balancing | ALB 에서 cross zone 부하 분산 지원 여부입니다. | bool | false | No |
| extra_ssl_certs | HTTPS 리스너에 적용할 추가 SSL 인증서를 정의 합니다. | list(map(string)) | <pre>[<br>  {<br>    "certificate_arn"  = "arn:aws:acm:your:certificate/9390..."<br>    "https_listener_index" = "0"<br>  },<br>  {<br>    "certificate_arn" = "arn:aws:acm:your:certificate/a398f9ad..."<br>    "https_listener_index" = "0"<br>  },<br>]</pre> | No |
| http_tcp_listeners | ALB 에 대한 HTTP 리스너 또는 TCP 포트를 정의 합니다. | any | [sample](#http-listener-sample) | No |
| http_tcp_listener_rules | ALB 에 대한 HTTP 리스너의 라우팅 규칙을 정의 합니다. | any | [sample](#http-listener-rules-sample) | No |
| https_listener_rules  ALB 에 대한 HTTPS 리스너의 라우팅 규칙을 정의 합니다. | | any | [sample](#https-listener-rules-sample) | No |
| idle_timeout | 연결이 유휴 상태로 허용 되는 시간(초)입니다. | number | 60 | No |
| ip_address_type | 로드 밸런서의 서브넷에서 사용하는 IP 주소 유형입니다. 가능한 값은 ipv4 및 dualstack 입니다. | string | "ipv4"| No |
| load_balancer_create_timeout | ALB 생성에 필요한 최대 허용 시간 입니다. | string | "10m" | No |
| load_balancer_delete_timeout | ALB 삭제에 필요한 최대 허용 시간 입니다. | string | "10m" | No |
| load_balancer_update_timeout | ALB 수정 반영에 필요한 최대 허용 시간 입니다. | string | "10m" | No |
| load_balancer_type | 로드 밸런서 유형 입니다. 가능한 값은 `application` 또는 `network` 입니다. | string | "application" | No |
| internal | Internal 내부 전용 로드 밸런서 여부입니다. | bool | false | No |
| access_logs | 로드 밸런서 액세스 로그 설정 입니다. | map(string) | - | No |
| subnets | 로드 밸런서와 연결 될 Subnet 아이디 입니다. | list(string) |["subnet-1a2b3c4d", "subnet-1a2b3c4e", "subnet-1a2b3c4f"] | No |
| subnet_mapping | 로드 밸런서와 연결 될 Subnet 및 할당된 EIP 를 정의 합니다. | list(map(string)) | <pre>[<br>  {<br>    subnet_id = "subnet-1a2b3c4d"<br>    allocation_id = "eipalloc-0e44fc50aaea6"<br>  },<br>  {<br>    subnet_id = "subnet-1a2b3c4e"<br>    allocation_id = "eipalloc-0e44fc50aaea6"<br>  }<br>]</pre> | No |
| lb_tags | 로드 밸런서 태그 속성 입니다. | map(string) | {Key1 = "value1"} | No |
| https_listeners_tags | ALB 의 HTTPS 리스너를 위한 태그 속성 입니다. | map(string) | {Key1 = "value1"} | No |
| https_listener_rules_tags | ALB 의 HTTPS 리스너 룰을 위한 태그 속성 입니다. | map(string) | {Key1 = "value1"} | No |
| listener_ssl_policy_default | Public 로드 밸런서에서 HTTPS 를 사용하는 경우 적용될 보안 정책 입니다. | string | "ELBSecurityPolicy-2016-08" | No |
| http_tcp_listeners_tags | ALB 의 HTTP 및 TCP 리스너를 위한 태그 속성 입니다. | map(string) | {Key1 = "value1"} | No |
| http_tcp_listener_rules_tags | ALB 의 HTTP 및 TCP 리스너 룰을 위한 태그 속성 입니다. | map(string) | {Key1 = "value1"} | No |
| target_groups | 로드 밸런서의 대상 그룹을 정의 합니다. | any | [sample](#target-group-sample) | No |
| security_groups | 로드 밸런서에 연결된 보안 그룹을 정의 합니다. | list(string) | ["sg-edcd9784", "sg-edcd9785"] | No |
| vpc_id | 로드 밸런서가 배치될 VPC 아이디 입니다. | string | - | No |
| context | 프로젝트에 관한 리소스를 생성 및 관리에 참조 되는 정보로 표준화된 네이밍 정책 및 리소스를 위한 속성 정보를 포함하며 이를 통해 데이터 소스 참조에도 활용됩니다. | object({}) | - | Yes |
| _____________________________________ | ____________________________________________________ | _ | _ | _ |


## Outputs

| Name | Description |
|------|-------------|
| http_tcp_listener_arns  |	The ARN of the TCP and HTTP load balancer listeners created. |
| http_tcp_listener_ids  |	The IDs of the TCP and HTTP load balancer listeners created. |
| https_listener_arns  |	The ARNs of the HTTPS load balancer listeners created. |
| https_listener_ids  |	The IDs of the load balancer listeners created. |
| lb_arn  |	The ID and ARN of the load balancer we created. |
| lb_arn_suffix  |	ARN suffix of our load balancer - can be used with CloudWatch. |
| lb_dns_name  |	The DNS name of the load balancer. |
| lb_id  |	The ID and ARN of the load balancer we created. |
| lb_zone_id  |	The zone_id of the load balancer to assist with creating DNS records. |
| target_group_arn_suffixes  |	ARN suffixes of our target groups - can be used with CloudWatch. |
| target_group_arns  |	ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target_group_names  |	Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |