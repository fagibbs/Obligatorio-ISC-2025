module "network" {
  source = "./Network"

  vpc_cidr        = var.vpc_cidr
  public_subnet_a = var.public_subnet_a
  public_subnet_b = var.public_subnet_b
  private_app_az1 = var.private_app_az1
  private_app_az2 = var.private_app_az2
  private_db_az1  = var.private_db_az1
  private_db_az2  = var.private_db_az2
  region          = var.region
}

module "services" {
  source = "./Services"
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
  project_name   = var.project_name
}

module "computers" {
  source            = "./Computers"
  vpc_id            = module.network.vpc_id
  app_subnets       = module.network.app_subnets
  sg_alb_id         = module.services.sg_alb_id
  sg_db_id          = module.db.sg_db_id
  target_group_arn  = module.services.target_group_arn
  key_name          = var.key_name
  instance_type     = var.instance_type
  ami_id            = data.aws_ami.amazon_linux.id 
}


module "db" {
  source = "./DB"

  vpc_id     = module.network.vpc_id
  db_subnets = module.network.db_subnets
  sg_app_id  = module.computers.sg_app_id

  db_username = var.db_username
  db_password = var.db_password
}
