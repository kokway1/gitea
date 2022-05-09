output "sg" {
  value = module.alb_sg_https.security_group_id
}

output "sg_ec2" {
  value = module.ec2_sg_https.security_group_id
}

output "vpc" {
  value = {
    public_subnets   = ["subnet-008300effd1948ae0", "subnet-f66cf79f"]
    vpc_id           = "vpc-156cf77c"
    }
}

output "subnet_id" {
  value = "subnet-008300effd1948ae0"
}
