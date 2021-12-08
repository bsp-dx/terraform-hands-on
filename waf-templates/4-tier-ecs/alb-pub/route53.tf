resource "aws_route53_record" "web_public" {
  zone_id         = data.aws_route53_zone.this.id
  name            = format("web.%s", module.ctx.domain)
  type            = "CNAME"
  ttl             = "300"
  records         = [module.alb_pub.lb_dns_name]
  allow_overwrite = true
  depends_on = [module.alb_pub]
}