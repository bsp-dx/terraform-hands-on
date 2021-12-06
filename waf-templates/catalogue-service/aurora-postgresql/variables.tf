variable "aurora_db_password" {
  default = "패스워드 노출을 방지 하기 위해, TF_VAR_aurora_db_password 환경 변수를 설정 하세요. [Ex: export TF_VAR_aurora_db_password='your_rds_password'] "
  type = string
}
