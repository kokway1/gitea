module "alb_sg_https" {
  source = "../terraform-aws-modules/security-group/"
  name        = var.namespace
  description = "Security group for ALB with http & https open"
  vpc_id      = var.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp", "https-443-tcp"]
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_rules             = ["all-tcp"]
}

module "ec2_sg_https" {
  source = "../terraform-aws-modules/security-group/"
  name        = var.namespace
  description = "Security group for EC2 with http & https open"
  vpc_id      = var.vpc.vpc_id

  ingress_cidr_blocks      = ["10.0.0.0/8"]
  ingress_rules            = ["http-80-tcp", "https-443-tcp"]
}
