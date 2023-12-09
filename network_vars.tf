# VPC vars 
variable "VPC_cidr" {}

# Subnet vars
variable "subnet_count" {}
variable "subnet_size" {}
variable "subnet_tier" {}
locals {
  # generate subnet number to calculate subnet cidr
  subnets = range(var.subnet_count)

  # generate subnet netmask i.e 3 for 6 (2^3)
  net_mask = ceil(log( var.subnet_count, 2))

  # generates subnet cidrs by concatinating 
  subnet_cidrs = cidrsubnets( var.VPC_cidr, local.net_mask, local.net_mask, local.net_mask, local.net_mask, local.net_mask, local.net_mask )
 
  # Generates map of az and tier for subnet_cidr ( cidr = {az="",tier=""})
  subnet_value = {for s in local.subnets : local.subnet_cidrs[s] => tomap({
  az = data.aws_availability_zones.subnet_az.names[ s % 2 ]
  tier = "${var.subnet_tier[ s % 3 ]}-${(s % 2)+1}" })}
}

data "aws_availability_zones" "subnet_az" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Route Table vars

locals {
  public_subnet_CIDR = { for i, v in local.subnet_value : i => v["tier"] if startswith( v["tier"], "frontend")}

  private_subnet_CIDR = { for i, v in local.subnet_value : i => v["tier"] if !startswith( v["tier"], "frontend")}

  public_subnet_CIDR_only = [ for i, v in local.subnet_value : i if startswith( v["tier"], "frontend")]
}


