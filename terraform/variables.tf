# =====================================
# ESIGELEC Lab 2 - Variables (Minimal)
# =====================================

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "esigelec-lab2"
}