# Launch template resource
resource "aws_launch_template" "roboshop_templates" {
    for_each = var.components
    name = "${each.key}_template"
    image_id = data.aws_ami.roboshop_image.id
    instance_type = "t3.micro"
    update_default_version = true

    iam_instance_profile {
      name = "GetParams"
    }              

     network_interfaces {
      associate_public_ip_address = true 
      description = true 
      security_groups = [startswith(each.key, "frontend") ? aws_security_group.roboshop_frontend_sgw.id : aws_security_group.roboshop_app_sgw.id ]

    } 


    instance_market_options {
      market_type = "spot"
      spot_options {
        spot_instance_type = "one-time"
      }
    }

    user_data = local.components_user_data[each
    .key]
}

# ASG resource
resource "aws_autoscaling_group" "roboshop_ASG" {
    for_each = var.components

    name = "${each.key}_ASG"

    launch_template {
      id = aws_launch_template.roboshop_templates[each.key].id
    }

    desired_capacity = 1
    min_size = 1
    max_size = 4

    vpc_zone_identifier = startswith( each.key, "frontend") ? local.frontend_subnet_id : local.web_subnet_id 

    target_group_arns = [ aws_lb_target_group.roboshop_TG[each.key].arn ]

    tag {
      key = "Name"
      value = "${each.key}_instance"
      propagate_at_launch = true
    }

    depends_on = [aws_nat_gateway.Public_NAT, aws_docdb_cluster.roboshop_mongodb, aws_elasticache_cluster.roboshop_redis, aws_db_instance.roboshop_mysql, aws_mq_broker.roboshop_rabbitmq]
}


resource "aws_autoscaling_policy" "roboshop_ASG_scaling_policy"{
  for_each = var.components
  name = "${each.key}_ASG_scaling_policy"

  autoscaling_group_name = aws_autoscaling_group.roboshop_ASG[each.key].name
  
  policy_type = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
  estimated_instance_warmup = 100
} 


resource "aws_autoscaling_attachment" "roboshop_ASG_TG" {
  for_each = var.components
  autoscaling_group_name = aws_autoscaling_group.roboshop_ASG[each.key].id
  lb_target_group_arn    = aws_lb_target_group.roboshop_TG[each.key].arn
}

# Target group resource
resource "aws_lb_target_group" "roboshop_TG"{
    for_each = var.components

    name = "${each.key}-TG"
    vpc_id = aws_vpc.roboshop_vpc.id
    
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


