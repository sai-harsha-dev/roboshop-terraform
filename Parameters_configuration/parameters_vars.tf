variable "db_pass" {}
variable "app_tier_components_dns" {}

output "mongoip_out" {
  value = aws_ssm_parameter.mongoip.value
}

output "rabbitmqip_out" {
  value = aws_ssm_parameter.rabbitmqip.value
}

output "mysqlip_out" {
  value = aws_ssm_parameter.mysqlip.value
}

output "redisip_out" {
  value = aws_ssm_parameter.redisip.value
}

output "docdbpass_value_out" {
  value = aws_ssm_parameter.docdbpass.value
}