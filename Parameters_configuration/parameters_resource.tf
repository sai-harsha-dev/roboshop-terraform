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
