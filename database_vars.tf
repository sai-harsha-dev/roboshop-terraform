variable "db_componets" {
  type = map(any)
}

locals {
   db_az_names = [ for i, k in local.subnet_value : k.az if startswith(k.tier, "database")]  
}

# SG vars
locals {
  db_subnet_id = [ for i, k in local.private_subnet_CIDR : aws_subnet.roboshop_subnets[i].id if startswith(k, "database")]
}


# redis vars
variable "Redis_instance" {}