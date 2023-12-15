variable "components" {}
variable "TG_arn" {}
variable "private_subnet_CIDR" {}
variable "public_subnet_CIDR_only" {}
variable "frontend_sgw_id" {}
variable "app_sgw_id" {}
variable "web_subnet_id" {}
variable "frontend_subnet_id" {}

locals {
  web_subnet = [ for i, k in var.private_subnet_CIDR : i if startswith( k, "web") ]
  /* web_subnet_id = [ for i  in local.web_subnet : aws_subnet.roboshop_subnets[i].id ]
  frontend_subnet_id = [ for i  in var.public_subnet_CIDR_only : aws_subnet.roboshop_subnets[i].id ] */
}

locals {
  components_user_data = { for i in var.components : i => filebase64("ASG_configuration/user_data/${i}.sh") } 
}

data "aws_ami" "roboshop_image" {
  filter {
    name = "name"
    values = ["Centos-8-DevOps-Practice"]
  }

  filter {
    name = "image-id" 
    values = ["ami-03265a0778a880afb"]
  }
}