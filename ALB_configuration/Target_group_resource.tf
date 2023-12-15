# Target group resource
resource "aws_lb_target_group" "roboshop_TG"{
    for_each = toset(var.components)

    name = "${each.key}-TG"
    vpc_id = var.vpc_id
    
    target_type = "instance"
    port = startswith(each.key, "frontend") ? 80 : 8080
    protocol = "HTTP"
    load_balancing_algorithm_type = "least_outstanding_requests"

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      interval = 15
      path = "/health" 
      port = "traffic-port" 
    }

    tags = {
      Name = "${each.key}_TG"
    }
} 
