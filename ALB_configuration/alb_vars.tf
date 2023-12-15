variable "VPC_cidr" {}
variable "frontend_subnet_value" {}
variable "web_subnet_value" {}
#variable "Public_alb_subnet" {}
variable "HTTPS_cert" {}
variable "components" {}
variable "vpc_id" {}
variable "app_tier_components_dns"{}

locals {
  TG_arn = { for i in var.components : i => aws_lb_target_group.roboshop_TG[i].arn }
}

#Output values

output "Public_ALB_dns_name_out" {
  value = aws_lb.roboshop_Public_ALB.dns_name
}

output "Public_ALB_zone_id_out" {
  value = aws_lb.roboshop_Public_ALB.zone_id
}

output "Private_ALB_dns_name_out" {
  value = aws_lb.roboshop_Internal_ALB.dns_name
}

output "Private_ALB_zone_id_out" {
  value = aws_lb.roboshop_Internal_ALB.zone_id
}

output "TG_arn_out" {
  value = local.TG_arn
}

output "frontend_sgw_id_out" {
  value = aws_security_group.roboshop_frontend_sgw.id
}

output "app_sgw_id_out" {
  value = aws_security_group.roboshop_app_sgw.id
}