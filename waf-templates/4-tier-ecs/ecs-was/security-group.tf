locals {
  was_sg_name = "${module.ctx.name_prefix}-was-sg"
}

resource "aws_security_group" "was" {
  name        = local.was_sg_name
  description = "Allow Public ALB inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description = "HTTP API from Any"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  ingress {
    description = "HTTP API from Any"
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  ingress {
    description = "Ingress for docker containers"
    from_port   = 32768
    to_port     = 61000
    protocol    = "ALL"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.was_sg_name })
}