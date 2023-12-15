variable "cert_domain" {}

output "Public_cert_domain_validation_options_out" {
  value = aws_acm_certificate.roboshop_cert.domain_validation_options
}

output "Public_cert_arn_out" {
  value = aws_acm_certificate.roboshop_cert.arn
}

output "HTTPS_cert_out" {
  value = aws_acm_certificate.roboshop_cert.arn
}