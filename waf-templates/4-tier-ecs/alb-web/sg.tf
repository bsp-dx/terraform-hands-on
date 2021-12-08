locals {
  web_alb_sg_name = "${module.ctx.name_prefix}-web-alb-sg"
}

resource "aws_security_group" "web" {
  name        = local.web_alb_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description     = "HTTP 80 for Frontend"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [data.aws_security_group.pub.id]
  }

  ingress {
    description     = "HTTP 8080 for Backend API"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [data.aws_security_group.pub.id]
  }

  ingress {
    description     = "HTTP 8088 for Backend API"
    from_port       = 8088
    to_port         = 8088
    protocol        = "tcp"
    security_groups = [data.aws_security_group.pub.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.web_alb_sg_name })
}