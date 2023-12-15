# Launch template resource
resource "aws_launch_template" "roboshop_templates" {
    for_each = toset(var.components)
    name = "${each.key}_template"
    image_id = data.aws_ami.roboshop_image.id
    instance_type = "t3.micro"
    update_default_version = true

    iam_instance_profile {
      name = "GetParams"
    }              

     network_interfaces {
      associate_public_ip_address = false 
      description = true 
      security_groups = [startswith(each.key, "frontend") ? var.frontend_sgw_id : var.app_sgw_id ]

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
    for_each = toset(var.components)

    name = "${each.key}_ASG"

    launch_template {
      id = aws_launch_template.roboshop_templates[each.key].id
    }

    desired_capacity = 1
    min_size = 1
    max_size = 4

    vpc_zone_identifier = startswith( each.key, "frontend") ? var.frontend_subnet_id : var.web_subnet_id 

    target_group_arns = [ var.TG_arn[each.key]]

    tag {
      key = "Name"
      value = "${each.key}_instance"
      propagate_at_launch = true
    }

    #depends_on = [aws_nat_gateway.Public_NAT, aws_docdb_cluster.roboshop_mongodb, aws_elasticache_cluster.roboshop_redis, aws_db_instance.roboshop_mysql, aws_mq_broker.roboshop_rabbitmq]
}


resource "aws_autoscaling_policy" "roboshop_ASG_scaling_policy"{
  for_each = toset(var.components)
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
  for_each = toset(var.components)
  autoscaling_group_name = aws_autoscaling_group.roboshop_ASG[each.key].id
  lb_target_group_arn    = var.TG_arn[each.key]
}