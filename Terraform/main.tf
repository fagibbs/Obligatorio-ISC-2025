module "network" {
  source   = "./Network"
  vpc_cidr = var.vpc_cidr
}

module "services" {
  source         = "./Services"
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
}

module "computers" {
  source            = "./Computers"
  vpc_id            = module.network.vpc_id
  app_subnets       = module.network.app_subnets
  sg_alb_id         = module.services.sg_alb_id
  target_group_arn  = module.services.target_group_arn
  key_name          = var.key_name
}

module "db" {
  source     = "./DB"
  vpc_id     = module.network.vpc_id
  db_subnets = module.network.db_subnets
  sg_app_id  = module.computers.sg_app_id
  key_name   = var.key_name

  db_username = var.db_username
  db_password = var.db_password
}
