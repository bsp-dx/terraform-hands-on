locals {
  sg_name = format("%s-redis-sg", module.ctx.name_prefix)
}
resource "aws_security_group" "redis" {
  name        = local.sg_name
  description = "Allow Apps inbound traffic for AWS Elasticache Redis"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description = "Elasticache-Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.was : s.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(module.ctx.tags, { Name = local.sg_name })
}