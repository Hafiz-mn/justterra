output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

