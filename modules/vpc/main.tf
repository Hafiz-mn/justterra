module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name             = var.vpc_name
  cidr             = var.vpc_cidr
  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets

  enable_dns_hostnames = true
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
