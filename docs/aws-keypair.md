# EC2 Keypair 등록

ssh-keygen 유틸리티를 통해 rsa 알고리즘 기반의 비대칭키를 생성하고, 공개(Public Key) 키는 EC2 서비스의 Keypair 에 등록 하고, 비밀(Private Key)키를 이용해 EC2 인스턴스에 접속 합니다.


## keypair 생성
RSA 비대칭키를 생성 합니다.

```shell
ssh-keygen -t rsa -b 4096 -C "my-key" -f ~/.ssh/id_rsa
```
위와 같이 생성된 keypair 의 공개 키(public-key)를 AWS EC2 의 Key Pair 서비스에 등록 합니다.


## AWS CLI 를 통한 EC2 키 페어에 공개키 등록 샘플
```shell
aws ec2 import-key-pair --key-name "my-keypair" --public-key-material fileb://~/.ssh/id_rsa.pub
```

## Terraform 을 통한 EC2 키 페어에 공개키 등록 샘플
```hcl
resource "aws_key_pair" "my_key" {
  key_name = "my-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}
```

## keypair 를 적용한 EC2 인스턴스 생성 참고 
테라폼을 통해 EC2 를 생성할 때 keypair 서비스에를 등록한 이름을 사용 합니다.
```hcl
resource "aws_instance" "my_ec2" {
  ami           = "ami-0ba5cd124d7a79612" # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - X86
  instance_type = "t3.small"

  key_name      = "my-keypair" # AWS keypair 서비스에 등록한 key 이름을 기입 합니다.
}
```

## SSH 접속 예시
```shell
ssh -i ~/.ssh/id_rsa ubuntu@${target_ip_addr}
```

## 참고 자료
- [AWS import-key-pair](https://docs.aws.amazon.com/cli/latest/reference/ec2/import-key-pair.html)