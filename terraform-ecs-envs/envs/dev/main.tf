provider "aws" { 
         region = "eu-north-1"
}

data "aws_ami" "amazon_linux" { 
        most_recent = true

        filter { 
        
           name = "name" 
           values = ["al2023-ami-ecs-hvm-*-kernel-6.1-x86_64"] 

}

owners = ["591542846629"]

}

resource "aws_ecs_cluster" "ecs" { 
          
          name = "dev-ecs-cluster" 
}

resource "aws_ecs_task_definition" "nginx" {

  family = "nginx-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  
  container_definitions = jsonencode([
  {
    name = "nginx"
    image = "nginx:latest"
    essential = true
    portMappings = [
    {
      containerPort = 80
      hostPort = 80
      protocol = "tcp"
    }
   ]
  }
 ])
}
module "vpc" {
   source = "terraform-aws-modules/vpc/aws"
   version = "5.19.0"

   name = "DEV-VPC"
   cidr = "10.0.0.0/16"

   azs = ["eu-north-1a", "eu-north-1b"]
   private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
   public_subnets = ["10.0.101.0/24","10.0.102.0/24"]
   enable_dns_hostnames = true
}

resource "aws_security_group" "alb_sg" {
   name = "alb-sg-dev"
   vpc_id = module.vpc.vpc_id

   ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_ecs_service" "nginx" {
   name = "nginx-service"
   cluster = aws_ecs_cluster.ecs.id
   task_definition = aws_ecs_task_definition.nginx.arn
   desired_count = 1
   launch_type = "FARGATE"

  network_configuration {
   subnets = module.vpc.public_subnets
   security_groups = [module.vpc.default_security_group_id]
   assign_public_ip = true
}
  load_balancer {
  target_group_arn = aws_lb_target_group.ecs_tg.arn
  container_name = "nginx"
  container_port = 80
}
depends_on = [aws_lb_listener.http]
}


resource "aws_lb" "app" {

   name = "sufl-lb-dev"
   load_balancer_type = "application"
   security_groups = [aws_security_group.alb_sg.id]
   subnets = module.vpc.public_subnets 
  }
resource "aws_lb_target_group" "ecs_tg" {
     name = "ecs-tg-dev"
     port = 80
     protocol = "HTTP"
     vpc_id = module.vpc.vpc_id
     target_type = "ip"
}
resource "aws_lb_listener" "http"{
 load_balancer_arn = aws_lb.app.arn
 port = 80
 protocol = "HTTP"
 
default_action {
 type = "forward"
 target_group_arn = aws_lb_target_group.ecs_tg.arn
 }
}

terraform {
 backend "s3" {
  bucket = "sufl-terraform"
  key = "dev/terraform.tfstate"
  region = "eu-north-1"
  dynamodb_table = "terraform-locks"
  encrypt = true
 }
}

