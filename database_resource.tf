# RDS subnet group
resource "aws_db_subnet_group" "roboshop_sg"{
    name = "roboshop_sg"
    subnet_ids = local.db_subnet_id
    tags = {
        name = "roboshop_sg"
    }
}

resource "aws_elasticache_subnet_group" "roboshop_sg"{
    name = "redis-sg"
    subnet_ids = local.db_subnet_id
    tags = {
        name = "redis_sg"
    }
}

# DB SGW resources
resource "aws_security_group" "roboshop_db_sgw" {
    for_each = var.db_componets
    name = "${each.key}_SGW"
    vpc_id = aws_vpc.roboshop_vpc.id

    tags = {
        name = "${each.key}_SGW"
    }
}

resource "aws_vpc_security_group_ingress_rule" "db_ingress_rule"{
    for_each = var.db_componets
    security_group_id = aws_security_group.roboshop_db_sgw[each.key].id
    from_port = each.value
    to_port = each.value
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    #referenced_security_group_id = aws_security_group.roboshop_app_sgw.id
}

resource "aws_vpc_security_group_egress_rule" "db_egress_rule" {
    for_each = var.db_componets
    security_group_id = aws_security_group.roboshop_db_sgw[each.key].id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_security_group" "roboshop_app_sgw"{
    name ="roboshop_app_sgw"
    vpc_id = aws_vpc.roboshop_vpc.id

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

resource "aws_security_group" "roboshop_frontend_sgw"{
    name = "roboshop_frontend_sgw"
    vpc_id = aws_vpc.roboshop_vpc.id

    tags = {
        name = "roboshop_frontend_sgw"
    }
}

resource "aws_vpc_security_group_ingress_rule" "frontend_ssh_ingress_rule"{
    security_group_id = aws_security_group.roboshop_frontend_sgw.id
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
}

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

# Mongo/DocDB resource
 resource "aws_docdb_cluster" "roboshop_mongodb"{
    cluster_identifier = "roboshop-mongodb"
    engine_version = "4.0.0"
    master_username = "Harsha"
    master_password = aws_ssm_parameter.docdbpass.value
    port = "27017"

    vpc_security_group_ids = [ aws_security_group.roboshop_db_sgw["mongodb"].id ]
    #availability_zones =  local.db_az_names
    db_subnet_group_name = "roboshop_sg"
    db_cluster_parameter_group_name = "mongodb-pg"

    skip_final_snapshot = true
    apply_immediately = true

    tags = {
      name = "roboshop_mongodb"
    }

    depends_on = [aws_db_subnet_group.roboshop_sg, aws_docdb_cluster_parameter_group.mongodb_pg ]
}

resource "aws_docdb_cluster_parameter_group" "mongodb_pg" {
    name = "mongodb-pg"
    family = "docdb4.0"

    parameter {
        name  = "tls"
        value = "disabled"
    }
}

resource "aws_docdb_cluster_instance" "roboshop_mongodb_instances" {
    count = 1
    
    identifier = "roboshop-mongodb-instances"
    instance_class = "db.t3.medium"
  
    cluster_identifier = "roboshop-mongodb"

    apply_immediately = true

    depends_on = [ aws_docdb_cluster.roboshop_mongodb ]
}


# Redis resource
resource "aws_elasticache_cluster" "roboshop_redis" {
    cluster_id = "roboshop-redis"

    engine = "redis"
    engine_version = "6.2"
    node_type = var.Redis_instance
    num_cache_nodes = 1

    security_group_ids = [ aws_security_group.roboshop_db_sgw["redis"].id ]
    subnet_group_name = "redis-sg"
    parameter_group_name = "default.redis6.x"
    
    preferred_availability_zones = [local.db_az_names[0]]
    
    apply_immediately = true
    
    tags = {
        name = "roboshop-redis"
    }

    depends_on = [ aws_elasticache_subnet_group.roboshop_sg ]
}

# MySql resource

resource "aws_db_instance" "roboshop_mysql" {
    db_name = "roboshopmysql"
    identifier = "roboshopmysql"

    instance_class = "db.t3.micro"
    allocated_storage = 10
    
    engine = "mysql"
    engine_version = "5.7"

    multi_az = true
    db_subnet_group_name = "roboshop_sg"
    vpc_security_group_ids = [aws_security_group.roboshop_db_sgw["mysql"].id]

    username = "Harsha"
    password = aws_ssm_parameter.docdbpass.value

    apply_immediately = true

    skip_final_snapshot = true

    tags = {
      name = "roboshop-mysql"
    }

    depends_on = [ aws_db_subnet_group.roboshop_sg ]
}


# Rabbitmq resource

resource "aws_mq_broker" "roboshop_rabbitmq"{
    broker_name = "roboshop-rabbitmq"

    engine_type = "RabbitMQ"
    engine_version = "3.11.20"
    host_instance_type = "mq.t3.micro"
    
    security_groups = [aws_security_group.roboshop_db_sgw["rabbitmq"].id]
    subnet_ids = [local.db_subnet_id[0]]
    
    user {
      username = "Harsha"
      password = aws_ssm_parameter.docdbpass.value
    }
    
    apply_immediately = true

    tags = {
      name = "roboshop-rabbitmq"
    }
}