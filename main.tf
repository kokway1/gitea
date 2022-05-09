module "alb" {
  source      = "./modules/alb"
  namespace   = var.namespace
  vpc         = module.networking.vpc
  sg          = module.networking.sg
  instanceid  = module.ec2.instanceid
  cert_arn    = var.cert_arn
  }

module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
  vpc       = module.networking.vpc
  subnet_id = module.networking.subnet_id
}

module "ec2" {
  source    = "./modules/ec2"
  sg_ec2    = module.networking.sg_ec2
  subnet_id = module.networking.subnet_id
}

