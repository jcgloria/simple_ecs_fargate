variable "region" {
  description = "Region to deploy"
  type        = string
  default     = "eu-west-2"
}

variable "cluster_name" {
    description = "Name of the ECS cluster"
    type        = string
    default     = "my_cluster"
}

variable "task_name" {
    description = "Name of the ECS task definition"
    type        = string
    default     = "my_task"
}

variable "repo_name" {
    description = "Name of the ECR repository"
    type        = string
    default     = "my_repo"
}