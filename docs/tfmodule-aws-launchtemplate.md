# tfmodule-aws-launchtemplate

AWS EC2 인스턴스 론칭을 위한 시작 템플릿을 생성 하는 테라폼 모듈 입니다.

## Usage

```
# AMI 참조 
data "aws_ami" "tomcat" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 커스텀 user_data
data "template_file" "tomcat" {
  template = file("${path.module}/templates/tomcat.tpl")
  vars     = {
    name = "Symplesims"
  }
}

# Launch Template
module "lt_tomcat" {
  source = "git::https://github.com/bsp-dx/edu-terraform-aws.git?ref=tfmodule-aws-launchtemplate-v1.0.0"

  context          = var.context
  name             = "tomcat"
  image_id         = data.aws_ami.tomcat.id
  instance_type    = "t3.small"
  user_data_base64 = base64encode(data.template_file.tomcat.rendered)
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


## Input Variables
| Name | Description | Type | Example | Required |
|------|-------------|------|---------|:--------:|
| lt_name | launch template 이름 입니다. | string | - | Yes |
| description | launch template 설명 입니다. | string | - | No |
| ebs_optimized | EBS Optimized 설정 여부 입니다. | bool | false | No |
| image_id | EC2 AMI 이미지 아이디를 설정 합니다. | string | "ami-0252a84eb1d66c2a0" | Yes |
| instance_type | EC2 인스턴스 타입을 설정 합니다. | string | "t3.medium" | Yes |
| key_name | 터미널(SSH 등) 접속에 사용되는 public 인증 key 입니다.  | string | - | No |
| user_data_base64 | EC2 인스턴스 구동시 사용되는 커스텀 사용자 쉘 스크립트 입니다. | string | - | No |
| security_groups | EC2 인스턴스에 적용 될 보안 그룹 입니다. | list(string) | ["sg-03c86f9a0c3251e123", "sg-03c86f9a0c1222ea2" ] | No |
| default_version | launch template 버전 정보 입니 | string | - | No |
| disable_api_termination | EC2 인스턴스 종료 보호를 활성화 합니다.  | bool | false | No |
| instance_initiated_shutdown_behavior | EC2 인스턴스 종료 동작을 정의 합니다. ('stop' 또는 'terminate').  | string | "stop" | No |
| block_device_mappings | EC2 에 사용할 추가 볼륨 저장소를 정의 합니다.  | list(any) | <pre>block_device_mappings = [<br>    {<br>      device_name = '/dev/xvda'<br>      no_device   = 0<br>      ebs = {<br>            delete_on_termination = true<br>            encrypted             = true<br>            volume_size           = 20<br>            volume_type           = 'gp2'<br>        }<br>    },<br>    {<br>      device_name = '/dev/sda1'<br>      no_device   = 1<br>      ebs = {<br>        delete_on_termination = true<br>        volume_size           = 30<br>        volume_type           = 'gp2'<br>      }<br>    }<br>  ]</pre> | No |
| capacity_reservation_specification | EC2 인스턴스의 용량 예약 기본 설정을 정의 합니다. | any | <pre>capacity_reservation_specification = {<br>  capacity_reservation_preference = 'open'<br>  capacity_reservation_target {<br>      capacity_reservation_id = 'cr-1234abcd56EXAMPLE'<br>  }<br>}</pre> | No |
| cpu_options | EC2 인스턴스의 CPU 옵션을 설정 합니다.  | map(string) | <pre>cpu_options = {<br>  core_count       = 4<br>  threads_per_core = 2<br>}</pre> | No |
| credit_specification | EC2 인스턴스의 CPU 크레딧 정보를 정의 합니다.  | map(string) | <pre>credit_specification = {<br>  cpu_credits = "standard"<br>}</pre> | No |
| elastic_gpu_specifications | EC2 인스턴스에 확장 가능한 GPU 를 추가 합니다. | map(string) | <pre>elastic_gpu_specifications = {<br>  type = "test"<br>}</pre> | No |
| elastic_inference_accelerator | EC2 인스턴스에 연결할 Elastic Inference Accelerator 를 포함 합니다. | map(string) | <pre>elastic_inference_accelerator = {<br>  type = "eg1.2xlarge"<br>}</pre> | No |
| enclave_options | EC2 인스턴스의 Nitro Enclave 옵션을 활성화 합니다. | bool | - | No |
| hibernation_options | EC2 인스턴스의 hibernation 옵션을 활성화 합니다. | bool | - | No |
| iam_instance_profile_name | EC2 인스턴스의 Instance Profile Name 을 설정 합니다. | string | - | No |
| iam_instance_profile_arn  | EC2 인스턴스의 Instance Profile ARN 정보를 설정 합니다. | string | - | No |
| metadata_options | EC2 인스턴스의 메타데이터 및 사용자 데이터를 설정 합니다. | map(string) | <pre>metadata_options = {<br>  http_endpoint = "enabled"<br>  http_tokens   = "required"<br>  http_put_response_hop_limit = 1<br>}</pre> | No |
| monitoring | EC2 인스턴스 모니터링 활성화 여부를 설정 합니다. | bool | true | No |
| network_interfaces | EC2 인스턴스 구동시 커스텀 네트워크 인터페이스를 추가 합니다. | list(any) | <pre>network_interfaces = [{<br>  associate_public_ip_address = true<br>}]</pre> | No |
| placement | EC2 인스턴스 배치를 위한 배치 그룹을 설정 합니다. | map(string) | <pre>placement = {<br>  group_name = "my_pgname"<br>}</pre> | No |
| instance_tags | EC2 인스턴스에 적용 될 Tag를 설정 합니다. | map(string) | <pre>instance_tags = {<br>  Key1 = "Value1",<br>  Key2 = "Value2"<br>}</pre> | No |
| context | 프로젝트에 관한 리소스를 생성 및 관리에 참조 되는 정보로 표준화된 네이밍 정책 및 리소스를 위한 속성 정보를 포함하며 이를 통해 데이터 소스 참조에도 활용됩니다. | object({}) | - | Yes |
| _____________________________ | ______________________________________________________ | ___ | ___ | ___ |

### Variables Reference
- [capacity_reservation_specification](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/capacity-reservations-using.html) EC2 인스턴스의 용량 예약 기본 설정 참고
- [elastic_gpu_specifications](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics) EC2 인스턴스에 확장 가능한 GPU 참고
- [enclave_options](https://docs.aws.amazon.com/ko_kr/enclaves/latest/user/nitro-enclave.html) EC2 인스턴스 Nitro Enclave 옵션 참고
- [metadata_options](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) EC2 인스턴스 메타데이터 및 사용자 데이터 참고
- [placement](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/placement-groups.html) 배치 그룹 참고


## Output

| Name | Description | Example |
|------|-------------|------|
| launch_template_id | launch template 아이디 입니다. | "lt-0fb6ea8dbbfbe80c9" |
| launch_template_name | launch template 이름 입니다. | "my-web-lt" |
| launch_template_arn | launch template ARN 입니다. | "arn:aws:ec2:ap-northeast-2:11111111:launch-template/lt-0fb6ea8dbbfbe80c9" |
| launch_template_latest_version | launch template 최근 버전 입니다. | 1 |
