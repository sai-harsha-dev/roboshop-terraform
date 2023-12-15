# Private DNS resource
# Private zonne
resource "aws_route53_zone" "roboshop_private_zone" {
  name = "roboshop.com"

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "app_componets_record"{
  for_each = var.app_tier_components_dns
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = each.value
  type = "A"
  alias {
    name = var.Private_ALB_dns_name
    zone_id = var.Private_ALB_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

resource "aws_route53_record" "mongodb_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = var.mongoip
  type = "CNAME"
  ttl = 300
  records = [var.mongodbip_value]
  allow_overwrite = true
}

resource "aws_route53_record" "rabbitmq_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = var.rabbitmqip
  type = "CNAME"
  ttl = 300
  records = [var.rabbitmqip_value]
  allow_overwrite = true
}

resource "aws_route53_record" "mysql_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = var.mysqlip
  type = "CNAME"
  ttl = 300
  records = [var.mysqlip_value]
  allow_overwrite = true
}

resource "aws_route53_record" "redis_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = var.redisip
  type = "CNAME"
  ttl = 300
  records = [ var.redisip_value]
  allow_overwrite = true
}
