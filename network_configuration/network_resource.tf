# VPC resource
resource "aws_vpc" "roboshop_vpc" {
  cidr_block = var.VPC_cidr
  enable_dns_hostnames = true
   tags = {
    Name = "${var.project}_vpc"
  }
}

# Subnet resource
resource "aws_subnet" "roboshop_subnets" {
  for_each = local.subnet_value
  vpc_id = aws_vpc.roboshop_vpc.id
  cidr_block = each.key 
  availability_zone = each.value.az
  tags = {
    Name = "${var.project}_${each.value.tier}"
  }
}

# Route Table resource

  # Default Route Table resource
  resource "aws_default_route_table" "Public_RTB" {
    default_route_table_id = aws_vpc.roboshop_vpc.default_route_table_id

    route {
        cidr_block = var.VPC_cidr
        gateway_id = "local"
      }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Public_IGW.id
      
      }

    tags = {
      Name = "${var.project}_Public_RTB"
    }
  }


  # Private Route Table resource
  resource "aws_route_table" "Private_RTB" {
    for_each = local.public_subnet_CIDR
    vpc_id = aws_vpc.roboshop_vpc.id

    tags = {
      Name = each.value == "frontend-1" ? "Web_Private_RTB" : "Database_Private_RTB"
    }
  }

  resource "aws_route" "NAT_route" {
    for_each = local.public_subnet_CIDR
    route_table_id  = aws_route_table.Private_RTB[each.key].id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Public_NAT[each.key].id
  } 


  resource "aws_route_table_association" "Public_RTB_association" {
    for_each = local.public_subnet_CIDR
    subnet_id      = aws_subnet.roboshop_subnets[each.key].id
    route_table_id = aws_default_route_table.Public_RTB.id
  }

  resource "aws_route_table_association" "Private_RTB_association" {
    for_each = local.private_subnet_CIDR
    subnet_id      = aws_subnet.roboshop_subnets[each.key].id
    route_table_id = startswith(each.value , "web") ? aws_route_table.Private_RTB[local.public_subnet_CIDR_only[0]].id : aws_route_table.Private_RTB[local.public_subnet_CIDR_only[1]].id
  }


# Internet Gateway resource
resource "aws_internet_gateway" "Public_IGW" {
  vpc_id = aws_vpc.roboshop_vpc.id

  tags = {
    Name = "Public_IGW"
  }
}

# NAT Gateway resouce
resource "aws_nat_gateway" "Public_NAT" {
  for_each = local.public_subnet_CIDR
  allocation_id = aws_eip.NAT_eip[each.key].id
  subnet_id = aws_subnet.roboshop_subnets[each.key].id
  tags = {
    Name = "NAT_${each.value}"
  }
}

# EIP resource
resource "aws_eip" "NAT_eip" {
  for_each = local.public_subnet_CIDR
  domain = "vpc"
  public_ipv4_pool = "amazon"
  tags = {
    Name = "NAT_eip_${each.value}"
  }
}
