locals {
  pub_alb_sg_name      = "${module.ctx.name_prefix}-waf-alb-sg"
  internal_alb_sg_name = "${module.ctx.name_prefix}-web-alb-sg"
  internal_nlb_sg_name = "${module.ctx.name_prefix}-was-nlb-sg"
  internal_rds_sg_name = "${module.ctx.name_prefix}-rds-sg"
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.pub_alb_sg_name })
}

resource "aws_security_group" "internal_alb" {
  name        = local.internal_alb_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description     = "PORT 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.internal_alb_sg_name })
}

resource "aws_security_group" "internal_rds" {
  name        = local.internal_rds_sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description = "PORT 8080"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.internal_rds_sg_name })
}
