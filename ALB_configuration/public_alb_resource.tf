# ALB secrity group
resource "aws_security_group" "roboshop_publicalb_sgw" {
    name = "roboshop_publicalb_SGW"
    vpc_id = var.vpc_id

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
subnets = var.frontend_subnet_value
tags = {
    name = "roboshop-Public-ALB"
}
} 

# ALB Listener
resource "aws_lb_listener" "roboshop_Public_ALB_listener"{

load_balancer_arn = aws_lb.roboshop_Public_ALB.arn

port = "443"
protocol = "HTTPS"
ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
certificate_arn   = var.HTTPS_cert

default_action {
    type = "forward"
    forward {
    target_group {
        arn = aws_lb_target_group.roboshop_TG["frontend"].arn
        weight = 1
    }
    }
}

#depends_on = [ aws_acm_certificate_validation.roboshop_cert_validation ]

}