provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source = "../../../modules/vpc"

  vpc_name          = "DEV-VPC"
  vpc_cidr          = "10.0.0.0/16"
  azs               = ["eu-north-1a", "eu-north-1b"]
  private_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets    = ["10.0.101.0/24","10.0.102.0/24"]
 
}

module "ecs" {
  source = "../../../modules/ecs"

  cluster_name      = "dev-ecs-cluster"
  task_family       = "dev-task-family"
  cpu               = 256
  memory            = 512
  container_name    = "dev-app"
  container_image   = "nginx:latest"
  container_port    = 80
  service_name      = "dev-ecs-service"
  desired_count     = 2
  alb_name          = "dev-alb"
  target_group_name = "dev-tg"
  alb_sg_name       = "dev-alb-sg"
  subnets         = module.vpc.public_subnets
  alb_subnets     = module.vpc.public_subnets
  alb_vpc_id      = module.vpc.vpc_id
}

terraform {
  backend "s3" {
    bucket         = "sufl-terraform"
    key            = "dev/terraform.tfstate"   
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

