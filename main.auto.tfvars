# Project vars
project = "roboshop"

# Common vars (alb & SSM) value
app_tier_components_dns = { cart = "cart.roboshop.com",
                            catalogue = "catalogue.roboshop.com",
                            payment = "payment.roboshop.com",
                            shipping ="shipping.roboshop.com",
                            user = "user.roboshop.com",
                            dispatch = "dispatch.roboshop.com" }

# Network module vars value
    # VPC vars
    VPC_cidr= "192.168.0.0/21"

    # Subnet vars
    subnet_count = 6
    subnet_size = 256
    subnet_tier = ["frontend", "web", "database"]


# Database module vars value
db_componets = { mongodb:27017, redis:6379, mysql:3306, rabbitmq:5672 }
Redis_instance = "cache.t2.small"


# ALB module vars value
components = [ "catalogue", "user", "cart", "payment", "shipping", "dispatch", "frontend"]

# Parameters store vars value
db_pass = "VNSHarsha7999"