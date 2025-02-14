output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.demo.endpoint
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.demo.repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.demo.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.demo.name
}

output "task_execution_role_arn" {
  description = "The ARN of the task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  description = "The ARN of the task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "public_subnet_id" {
  description = "The ID of the first public subnet"
  value       = aws_subnet.public_1.id
}

output "ecs_security_group_id" {
  description = "The ID of the ECS security group"
  value       = aws_security_group.ecs_tasks.id
} 