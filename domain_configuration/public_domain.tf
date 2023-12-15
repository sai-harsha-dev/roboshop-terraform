# Public Zone
resource "aws_route53_zone" "roboshop_public_zone" {
  name = "sai-harsha-dev.click"
}

# Public zone records
resource "aws_route53_record" "public_zone_alb_record"{
  zone_id = aws_route53_zone.roboshop_public_zone.zone_id
  name = "www.sai-harsha-dev.click"
  type = "A"
  alias {
    name = var.Public_ALB_dns_name
    zone_id =var.Public_ALB_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

resource "aws_route53_record" "public_zone_cert_record" {
  for_each = {
    for dvo in var.Public_cert_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.roboshop_public_zone.zone_id

  depends_on = [ aws_route53domains_registered_domain.roboshop_domain  ]
}


resource "aws_route53domains_registered_domain" "roboshop_domain" {
  domain_name = "sai-harsha-dev.click"

  dynamic "name_server" {
    for_each = {for i in aws_route53_zone.roboshop_public_zone.name_servers : i => i}
    content {
      name = name_server.key
    }
  }
}

# ACM cert validation resource

resource "aws_acm_certificate_validation" "roboshop_cert_validation" {
  certificate_arn  = var.Public_cert_arn
  validation_record_fqdns = [aws_route53_record.public_zone_cert_record[var.cert_domain].fqdn]
}