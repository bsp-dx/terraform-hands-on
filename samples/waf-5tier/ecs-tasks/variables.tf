variable "create_nginx" {
  description = "Whether to create ECS nginx task job definitions."
  type = bool
}

variable "create_order_service" {
  description = "Whether to create ECS order-service task job definitions."
  type = bool
}