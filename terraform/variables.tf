
# AWS Configuration


variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# Project Information

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "gameapp"
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "dev"
}


# EC2 Configuration


variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "worker_count" {
  description = "Number of Worker Nodes"
  type        = number
  default     = 5
}


# SSH Configuration


variable "key_name" {
  description = "AWS EC2 Key Pair Name"
  type        = string
}


# Networking


variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

# Ubuntu AMI


variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI"
  type        = string
}