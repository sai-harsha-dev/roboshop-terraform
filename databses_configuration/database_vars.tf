variable "db_componets" {
  type = map(any)
}
variable "subnet_value" {}
variable "private_subnet_CIDR" {}
variable "db_subnet_id" {}
variable "roboshop_vpc_id" {}
variable "db_password" {}

locals {
   db_az_names = [ for i, k in var.subnet_value : k.az if startswith(k.tier, "database")]  
}

# SG vars
/* locals {
  db_subnet_id = [ for i, k in var.private_subnet_CIDR : aws_subnet.roboshop_subnets[i].id if startswith(k, "database")]
} */


# redis vars
variable "Redis_instance" {}


output "mongodbip_value_out" {
  value = aws_docdb_cluster.roboshop_mongodb.endpoint
}

output "rabbitmqip_value_out" {
  value = aws_mq_broker.roboshop_rabbitmq.instances.0.endpoints.0
}

output "mysqlip_value_out" {
  value = aws_db_instance.roboshop_mysql.address
}

output "redisip_value_out" {
  value = aws_elasticache_cluster.roboshop_redis.cache_nodes[0].address
}