variable "project" {}
variable "db_pass" {}
variable "app_tier_components_dns" {}
locals {
  components_user_data = { for i in var.components : i => filebase64("user_data/${i}.sh") } 
}
variable "public_ns" {}
variable "cert_domain" {}