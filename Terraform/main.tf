# MÓDULO DE RED

# Crear la infraestructura de red base: VPC, subnets, IGW, NAT y route tables
module "network" {
  source = "./Network"
 # CIDR principal de la VPC
  vpc_cidr        = var.vpc_cidr

 # Subnets públicas donde irán ALB y NAT
  public_subnet_a = var.public_subnet_a
  public_subnet_b = var.public_subnet_b

 # Subnets privadas para capa de aplicación
  private_app_az1 = var.private_app_az1
  private_app_az2 = var.private_app_az2

 # Subnets privadas para capa de base de datos
  private_db_az1  = var.private_db_az1
  private_db_az2  = var.private_db_az2

 # Región AWS utilizada (parámetro disponible para futuras extensiones)
  region          = var.region
}

# _____________________________________
# MÓDULO DE SERVICIOS

# Crea el ALB, S3 logs, lifecycle y CloudWatch alarms
module "services" {
  source = "./Services"
 
 # VPC donde se despliegan el ALB y sus recursos
  vpc_id         = module.network.vpc_id

 # Subnets públicas donde está el ALB
  public_subnets = module.network.public_subnets
  project_name   = var.project_name
}

# ___________________________________
# MÓDULO DE COMPUTERS (APP)

# Crear las instancias de aplicación mediante ASG
module "computers" {
  source            = "./Computers"
 
 # VPC donde se lanzan las instancias
  vpc_id            = module.network.vpc_id

 # Subnets privadas de la capa de aplicación
  app_subnets       = module.network.app_subnets
 
 # Security Group del ALB (permitido como origen HTTP)
  sg_alb_id         = module.services.sg_alb_id

 # Security Group de la base de datos
  sg_db_id          = module.db.sg_db_id
 
 # Target Group del ALB donde se registran las instancias
  target_group_arn  = module.services.target_group_arn
 
 # Key pair para acceso SSH
  key_name          = var.key_name
 
 # Tipo de instancia EC2 de aplicación
  instance_type     = var.instance_type
  ami_id            = data.aws_ami.amazon_linux.id 
}

# _______________________________________
# MÓDULO DE BASE DE DATOS

# Crea la instancia EC2 que simula la base de datos MySQL
module "db" {
  source = "./DB"

  vpc_id     = module.network.vpc_id
  db_subnets = module.network.db_subnets
  sg_app_id  = module.computers.sg_app_id

  db_username = var.db_username
  db_password = var.db_password
}
