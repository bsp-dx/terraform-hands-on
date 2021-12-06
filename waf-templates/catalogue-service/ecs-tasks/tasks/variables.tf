variable "create_nginx" {
  description = "Whether to create nginx task job definitions."
  type = bool
}

variable "create_golang_api" {
  description = "Whether to create sample-golang-api task job definitions."
  type = bool
}