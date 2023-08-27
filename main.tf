terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# ECR Repository
resource "aws_ecr_repository" "my_repo" {
  name         = var.repo_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# ECS Task Execution Role
resource "aws_iam_role" "task_execution_role" {
  name = "my_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ] }
  )
}

# ECS Task Execution Policy (Add extra permissions to the task execution role if needed)
resource "aws_iam_policy" "task_execution_policy"{
    name = "my_ecs_task_execution_policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "logs:CreateLogStream",
                    "logs:CreateLogGroup",
                    "logs:PutLogEvents"
                ]
                Effect = "Allow"
                Resource = "*"
            },
        ]
    })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "task_execution_policy_attachment" {
    role = aws_iam_role.task_execution_role.name
    policy_arn = aws_iam_policy.task_execution_policy.arn
}

# ECS Fargate Task Definition + Container Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.task_name
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<DEFINITION
[
  {
    "name": "${var.task_name}",
    "image": "${aws_ecr_repository.my_repo.repository_url}:latest",
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "ecs/${var.task_name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs",
        "awslogs-create-group": "true"
      }
    }
  }
]
DEFINITION
}

# Outputs for clearer visibility in the terminal

output "repository_url" {
  value = aws_ecr_repository.my_repo.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.my_repo.name
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "task_name" {
  value = aws_ecs_task_definition.task.family
}







