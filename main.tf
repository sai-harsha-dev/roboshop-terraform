provider "aws" {
  shared_config_files      = ["..\\aws_config"]
  shared_credentials_files = ["..\\aws_creds"]
}

module "network" {
  source = "./network_configuration"
  project = var.project
  VPC_cidr = var.VPC_cidr
  subnet_count = var.subnet_count
  subnet_size = var.subnet_size
  subnet_tier = var.subnet_tier
}

module "databses" {
  source = "./databses_configuration"
  subnet_value = module.network.subnet_value_out
  private_subnet_CIDR = module.network.private_subnet_CIDR_out
  db_subnet_id = module.network.db_subnet_id_out
  roboshop_vpc_id = module.network.roboshop_vpc_id_out
  db_password = module.parameters.docdbpass_value_out
  Redis_instance = var.Redis_instance
  db_componets = var.db_componets
}

module "parameters" {
  source = "./Parameters_configuration"
  db_pass = var.db_pass
  app_tier_components_dns = var.app_tier_components_dns
}

module "Certificate" {
  source = "./domain_cert_configuration"
  cert_domain = "*.sai-harsha-dev.click"
}

module "ALB" {
  source = "./ALB_configuration"
  components = var.components
  VPC_cidr = var.VPC_cidr
  frontend_subnet_value = module.network.frontend_subnet_value_out
  web_subnet_value = module.network.web_subnet_value_out
  #Public_alb_subnet = module.network.Public_alb_subnet_out
  HTTPS_cert = module.Certificate.HTTPS_cert_out
  vpc_id = module.network.roboshop_vpc_id_out
  app_tier_components_dns = var.app_tier_components_dns
}

module "Domain" {
  source = "./domain_configuration"
  Public_ALB_dns_name = module.ALB.Public_ALB_dns_name_out
  Public_ALB_zone_id = module.ALB.Public_ALB_zone_id_out
  Private_ALB_dns_name = module.ALB.Private_ALB_dns_name_out
  Private_ALB_zone_id = module.ALB.Private_ALB_zone_id_out
  Public_cert_domain_validation_options = module.Certificate.Public_cert_domain_validation_options_out
  cert_domain = "*.sai-harsha-dev.click"
  Public_cert_arn = module.Certificate.Public_cert_arn_out 
  vpc_id = module.network.roboshop_vpc_id_out
  app_tier_components_dns = var.app_tier_components_dns
  mongoip = module.parameters.mongoip_out
  mongodbip_value = module.databses.mongodbip_value_out
  rabbitmqip = module.parameters.rabbitmqip_out
  rabbitmqip_value = module.databses.rabbitmqip_value_out
  mysqlip = module.parameters.mysqlip_out
  mysqlip_value = module.databses.mysqlip_value_out
  redisip = module.parameters.redisip_out
  redisip_value = module.databses.redisip_value_out
}


module "ASG" {
  source = "./ASG_configuration"
  components = var.components
  frontend_subnet_id = module.network.frontend_subnet_id_out
  web_subnet_id = module.network.web_subnet_id_out
  TG_arn = module.ALB.TG_arn_out
  private_subnet_CIDR = module.network.private_subnet_CIDR_out 
  public_subnet_CIDR_only = module.network.public_subnet_CIDR_only_out
  frontend_sgw_id = module.ALB.frontend_sgw_id_out
  app_sgw_id = module.ALB.app_sgw_id_out
}