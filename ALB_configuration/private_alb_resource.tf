# WEB SGW resources
resource "aws_security_group" "roboshop_app_sgw"{
    name ="roboshop_app_sgw"
    vpc_id = var.vpc_id

    tags = {
        name = "roboshop_app_sgw"
    }
} 

resource "aws_vpc_security_group_ingress_rule" "app_ingress_rule"{
    security_group_id = aws_security_group.roboshop_app_sgw.id
    from_port = 8080
    to_port = 8080
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    #referenced_security_group_id = aws_security_group.roboshop_frontend_sgw.id
}

resource "aws_vpc_security_group_egress_rule" "app_egress_rule" {
    security_group_id = aws_security_group.roboshop_app_sgw.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

# FRONTEND SGW resources
    resource "aws_security_group" "roboshop_frontend_sgw"{
        name = "roboshop_frontend_sgw"
        vpc_id = var.vpc_id

        tags = {
            name = "roboshop_frontend_sgw"
        }
    }

    /* resource "aws_vpc_security_group_ingress_rule" "frontend_ssh_ingress_rule"{
        security_group_id = aws_security_group.roboshop_frontend_sgw.id
        from_port = 22
        to_port = 22
        ip_protocol = "tcp"
        cidr_ipv4 = "0.0.0.0/0"
    } */

    resource "aws_vpc_security_group_ingress_rule" "frontend_http_ingress_rule"{
        security_group_id = aws_security_group.roboshop_frontend_sgw.id
        from_port = 80
        to_port = 80
        ip_protocol = "tcp"
        cidr_ipv4 = "0.0.0.0/0"
    }

    resource "aws_vpc_security_group_egress_rule" "frontend_egress_rule" {
        security_group_id = aws_security_group.roboshop_frontend_sgw.id
        cidr_ipv4 = "0.0.0.0/0"
        ip_protocol = "-1"
    }

    
# ALB resource
resource "aws_lb" "roboshop_Internal_ALB"{
  name = "roboshop-Internal-ALB"
  load_balancer_type = "application"
  internal = true
  security_groups = [aws_security_group.roboshop_app_sgw.id]
  preserve_host_header = true
  subnets = var.web_subnet_value
  tags = {
    name = "roboshop-Internal-ALB"
  }
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
