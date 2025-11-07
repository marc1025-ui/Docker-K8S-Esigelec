# =====================================
# ESIGELEC Lab 2 - Outputs
# =====================================

# Cluster info
output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

# Services info (web apps uniquement)
output "web_services" {
  description = "Information about web services"
  value = {
    for service_name, service in aws_ecs_service.web_apps : service_name => {
      name         = service.name
      cluster      = service.cluster
      desired_count = service.desired_count
      launch_type  = service.launch_type
    }
  }
}

# Task definitions
output "task_definitions" {
  description = "Task definition ARNs"
  value = {
    for task_name, task in aws_ecs_task_definition.apps : task_name => {
      family   = task.family
      revision = task.revision
      arn      = task.arn
    }
  }
}

# Instructions pour récupérer les IPs
output "get_public_ips_command" {
  description = "Command to get public IPs of running tasks"
  value = "aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --output table"
}

# ECR repositories (où sont tes images)
output "ecr_repositories" {
  description = "ECR repository URLs where images should be pushed"
  value = {
    for app_name in keys(local.apps) : app_name => "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${app_name}:v1"
  }
}

# Commandes utiles
output "useful_commands" {
  description = "Useful commands to manage the deployment"
  value = {
    list_services = "aws ecs list-services --cluster ${aws_ecs_cluster.main.name}"
    list_tasks    = "aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name}"
    describe_tasks = "aws ecs describe-tasks --cluster ${aws_ecs_cluster.main.name} --tasks $(aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --query 'taskArns[0]' --output text)"
    get_logs      = "aws logs tail /ecs/${var.project_name}/hello-world-nginx --follow"
  }
}