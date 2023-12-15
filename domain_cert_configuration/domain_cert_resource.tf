resource "aws_acm_certificate" "roboshop_cert" {
  domain_name = var.cert_domain
  validation_method = "DNS"
 validation_option {
    domain_name = "*.sai-harsha-dev.click"
    validation_domain = "sai-harsha-dev.click"
  } 
}