# Parameters Store resource
resource "aws_ssm_parameter" "docdbpass"{
    name = "docdbpass"
    type = "SecureString"
    value = var.db_pass
    data_type = "text"
    tags = {
      name = "docdbpass"
    }
} 

resource "aws_ssm_parameter" "mongoip"{
    name = "mongoip"
    type = "String"
    value = "mongodb.roboshop.com"
    data_type = "text"
    tags = {
      name = "mongoip"
    }
}

resource "aws_ssm_parameter" "rabbitmqip"{
    name = "rabbitmqip"
    type = "String"
    value = "rabbitmq.roboshop.com"
    data_type = "text"
    tags = {
      name = "rabbitmqip"
    }
}

resource "aws_ssm_parameter" "mysqlip"{
    name = "mysqlip"
    type = "String"
    value = "mysql.roboshop.com"
    data_type = "text"
    tags = {
      name = "mysqlip"
    }
}

resource "aws_ssm_parameter" "redisip"{
    name = "redisip"
    type = "String"
    value = "redis.roboshop.com" 
    data_type = "text"
    tags = {
      name = "redisip"
    }
} 

resource "aws_ssm_parameter" "app_components_dns"{
    for_each = var.app_tier_components_dns
    name = "${each.key}dns"
    type = "String"
    value = each.value
    data_type = "text"
    tags = {
      name = "${each.key}dns"
    }
}

# ALB  sgw resource

resource "aws_security_group" "roboshop_publicalb_sgw" {
    name = "roboshop_publicalb_SGW"
    vpc_id = aws_vpc.roboshop_vpc.id

    tags = {
        name = "roboshop_publicalb_SGW"
    }
}

resource "aws_vpc_security_group_ingress_rule" "roboshop_publicalb_sgw_ingress_rule"{
    security_group_id = aws_security_group.roboshop_publicalb_sgw.id
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "roboshop_publicalb_sgw_egress_rule" {
    security_group_id = aws_security_group.roboshop_publicalb_sgw.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

# ALB resource
resource "aws_lb" "roboshop_Public_ALB"{
  name = "roboshop-Public-ALB"
  load_balancer_type = "application"
  security_groups = [aws_security_group.roboshop_publicalb_sgw.id]
  preserve_host_header = true
  subnets = [ for i, k in local.subnet_value : aws_subnet.roboshop_subnets[i].id if startswith(k.tier, "frontend")]
  tags = {
    name = "roboshop-Public-ALB"
  }
} 

resource "aws_lb" "roboshop_Internal_ALB"{
  name = "roboshop-Internal-ALB"
  load_balancer_type = "application"
  internal = true
  security_groups = [aws_security_group.roboshop_app_sgw.id]
  preserve_host_header = true
  subnets = [ for i, k in local.subnet_value : aws_subnet.roboshop_subnets[i].id if startswith(k.tier, "web")]
  tags = {
    name = "roboshop-Internal-ALB"
  }
} 


resource "aws_lb_listener" "roboshop_Public_ALB_listener"{

  load_balancer_arn = aws_lb.roboshop_Public_ALB.arn
  
  port = "443"
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.roboshop_cert.arn
  
  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.roboshop_TG["frontend"].arn
        weight = 1
      }
    }
  }

  depends_on = [ aws_acm_certificate_validation.roboshop_cert_validation ]

}


resource "aws_lb_listener" "roboshop_Internal_ALB_listener"{

  load_balancer_arn = aws_lb.roboshop_Internal_ALB.arn
  
  port = "8080"
  protocol = "HTTP"
  
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Site doesn't exist"
      status_code  = "200"
    }
  }

}


resource "aws_lb_listener_rule" "roboshop_Internal_ALB_listener_rule" {
    for_each = var.app_tier_components_dns

    listener_arn = aws_lb_listener.roboshop_Internal_ALB_listener.arn

    condition {
      host_header {
        values = [ each.value ]
      }
    }

    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.roboshop_TG[each.key].arn
    }
    
}


# DNS resources
resource "aws_route53_zone" "roboshop_private_zone" {
  name = "roboshop.com"

  vpc {
    vpc_id = aws_vpc.roboshop_vpc.id
  }
}

resource "aws_route53_record" "app_componets_record"{
  for_each = var.app_tier_components_dns
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = each.value
  type = "A"
  alias {
    name = aws_lb.roboshop_Internal_ALB.dns_name
    zone_id = aws_lb.roboshop_Internal_ALB.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

resource "aws_route53_record" "mongodb_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = aws_ssm_parameter.mongoip.value
  type = "CNAME"
  ttl = 300
  records = [aws_docdb_cluster.roboshop_mongodb.endpoint]
  allow_overwrite = true
}

resource "aws_route53_record" "rabbitmq_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = aws_ssm_parameter.rabbitmqip.value
  type = "CNAME"
  ttl = 300
  records = [aws_mq_broker.roboshop_rabbitmq.instances.0.endpoints.0]
  allow_overwrite = true
}

resource "aws_route53_record" "mysql_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = aws_ssm_parameter.mysqlip.value
  type = "CNAME"
  ttl = 300
  records = [aws_db_instance.roboshop_mysql.address]
  allow_overwrite = true
}

resource "aws_route53_record" "redis_record"{
  zone_id = aws_route53_zone.roboshop_private_zone.zone_id
  name = aws_ssm_parameter.redisip.value
  type = "CNAME"
  ttl = 300
  records = [ aws_elasticache_cluster.roboshop_redis.cache_nodes[0].address]
  allow_overwrite = true
}


resource "aws_route53_zone" "roboshop_public_zone" {
  name = "sai-harsha-dev.click"
}

resource "aws_route53_record" "public_zone_alb_record"{
  zone_id = aws_route53_zone.roboshop_public_zone.zone_id
  name = "www.sai-harsha-dev.click"
  type = "A"
  alias {
    name = aws_lb.roboshop_Public_ALB.dns_name
    zone_id = aws_lb.roboshop_Public_ALB.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

resource "aws_route53_record" "public_zone_cert_record" {
  for_each = {
    for dvo in aws_acm_certificate.roboshop_cert.domain_validation_options : dvo.domain_name => {
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
# ACM resource

resource "aws_acm_certificate" "roboshop_cert" {
  domain_name = var.cert_domain
  validation_method = "DNS"
 validation_option {
    domain_name = "*.sai-harsha-dev.click"
    validation_domain = "sai-harsha-dev.click"
  } 
}

resource "aws_acm_certificate_validation" "roboshop_cert_validation" {
  certificate_arn         = aws_acm_certificate.roboshop_cert.arn
  validation_record_fqdns = [aws_route53_record.public_zone_cert_record[var.cert_domain].fqdn]
}