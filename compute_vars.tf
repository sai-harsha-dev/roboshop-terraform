variable "components" {
    type = set(string)
}

# Launch template vars
variable "git_repo" {}

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


#ASG vars
locals {
  web_subnet = [ for i, k in local.private_subnet_CIDR : i if startswith( k, "web") ]
  web_subnet_id = [ for i  in local.web_subnet : aws_subnet.roboshop_subnets[i].id ]
  frontend_subnet_id = [ for i  in local.public_subnet_CIDR_only : aws_subnet.roboshop_subnets[i].id ]
}