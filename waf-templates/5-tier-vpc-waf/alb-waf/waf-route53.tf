resource "aws_route53_record" "nginx_public" {
  zone_id = data.aws_route53_zone.this.id
  name    = format("nginx.%s", module.ctx.domain)
  type    = "CNAME"
  ttl     = "300"
  records = [module.alb_waf.lb_dns_name]
  allow_overwrite = true
}