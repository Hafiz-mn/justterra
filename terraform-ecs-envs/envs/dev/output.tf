output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "The public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "The private subnets"
  value       = module.vpc.private_subnets
}

output "ecs_cluster_id" {
  description = "The ECS Cluster ID"
  value       = aws_ecs_cluster.ecs.id
}

output "ecs_service_name" {
  description = "The ECS Service name"
  value       = aws_ecs_service.nginx.name
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.app.dns_name
}

