output "alb_public_id" {
  value = module.alb_public.lb_id
}

output "alb_web_id" {
  value = module.alb_web.lb_id
}

output "nlb_was_id" {
  value = module.nlb_was.lb_id
}