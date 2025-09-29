provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name          = "PROD-VPC"
  vpc_cidr          = "10.0.0.0/16"
  azs               = ["eu-north-1a", "eu-north-1b"]
  private_subnets   = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets    = ["10.1.101.0/24","10.1.102.0/24"]
  enable_dns_hostnames = true
}

module "ecs" {
  source = "../../modules/ecs"

  cluster_name   = "prod-ecs-cluster"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_subnets    = module.vpc.public_subnets
  alb_vpc_id     = module.vpc.vpc_id
}

terraform {
  backend "s3" {
    bucket         = "sufl-terraform"
    key            = "prod/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
