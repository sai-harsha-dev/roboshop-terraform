# Project vars
variable "project" {}

# Common vars (alb & SSM)
variable "app_tier_components_dns" {}

# Network module vars 
    # VPC vars
    variable "VPC_cidr" {}

    # Subnet vars
    variable "subnet_count" {}
    variable "subnet_size" {}
    variable "subnet_tier" {}


# Database module vars
variable "db_componets" {
  type = map(any)
}

    # redis vars
    variable "Redis_instance" {}

# Alb module
variable "components" {}

# Parameter module vars
variable "db_pass" {}