locals {
  pub_alb_sg_name = "${module.ctx.name_prefix}-pub-alb-sg"
}

resource "aws_security_group" "public_alb" {
  name        = local.pub_alb_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.pub_alb_sg_name })
}