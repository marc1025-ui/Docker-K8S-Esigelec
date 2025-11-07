# =====================================
# ESIGELEC Lab 2 - ECS MINIMAL
# =====================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# =====================================
# DATA SOURCES
# =====================================

data "aws_caller_identity" "current" {} // Récupère l'ID du compte AWS courant
data "aws_region" "current" {} // Récupère la région AWS courante

# Get default VPC and subnets
data "aws_vpc" "default" { 
  default = true
}

data "aws_subnets" "default" { // Récupère les subnets de la VPC par défaut
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# =====================================
# LOCAL VALUES - Apps du Lab 2
# =====================================

locals {
  # Les 5 apps du lab-docker/1_ContainersAndDocker_2/
  apps = {
    hello-world-nginx = {
      port = 8080
      cpu  = 256
      memory = 512
      replicas = 1
      has_service = true
    }
    hello-java = {
      port = 8080
      cpu  = 512
      memory = 1024
      replicas = 1
      has_service = true
    }
    ubi-info = {
      port = 0
      cpu  = 256
      memory = 512
      replicas = 0
      has_service = false
    }
    ubi-sleep = {
      port = 0
      cpu  = 256
      memory = 512
      replicas = 0
      has_service = false
    }
    ubi-echo = {
      port = 0
      cpu  = 256
      memory = 512
      replicas = 0
      has_service = false
    }
  }
}

# =====================================
# ECS CLUSTER
# =====================================

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name    = "${var.project_name}-cluster"
    Project = "ESIGELEC-Lab2"
  }
}

# =====================================
# IAM ROLE pour ECS
# =====================================

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# =====================================
# SECURITY GROUP
# =====================================

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  # Port 8080 pour les apps web
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Sortie complète
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-ecs-sg"
    Project = "ESIGELEC-Lab2"
  }
}

# =====================================
# ECR REPOSITORIES
# =====================================

resource "aws_ecr_repository" "app_repos" {
  for_each = local.apps

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project_name}-${each.key}-ecr"
    Project = "ESIGELEC-Lab2"
    App     = each.key
  }
}

# ECR Lifecycle Policy pour gérer la rétention des images
resource "aws_ecr_lifecycle_policy" "app_repos_policy" {
  for_each   = aws_ecr_repository.app_repos
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# =====================================
# CLOUDWATCH LOGS
# =====================================

resource "aws_cloudwatch_log_group" "app_logs" {
  for_each = local.apps

  name              = "/ecs/${var.project_name}/${each.key}"
  retention_in_days = 7

  tags = {
    Name    = "${var.project_name}-${each.key}-logs"
    Project = "ESIGELEC-Lab2"
    App     = each.key
  }
}

# =====================================
# TASK DEFINITIONS
# =====================================

resource "aws_ecs_task_definition" "apps" {
  for_each = local.apps

  family                   = "${var.project_name}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${each.key}:v2"
      essential = true

      # Port mapping seulement si l'app a un port
      portMappings = each.value.port > 0 ? [
        {
          containerPort = each.value.port
          protocol      = "tcp"
        }
      ] : []

      # Logs CloudWatch
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_logs[each.key].name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name    = "${var.project_name}-${each.key}-task"
    Project = "ESIGELEC-Lab2"
    App     = each.key
  }
}

# =====================================
# ECS SERVICES (seulement pour les apps web)
# =====================================

resource "aws_ecs_service" "web_apps" {
  for_each = {
    for app, config in local.apps : app => config
    if config.has_service && config.replicas > 0
  }

  name            = "${var.project_name}-${each.key}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.apps[each.key].arn
  desired_count   = each.value.replicas
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  tags = {
    Name    = "${var.project_name}-${each.key}-service"
    Project = "ESIGELEC-Lab2"
    App     = each.key
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}