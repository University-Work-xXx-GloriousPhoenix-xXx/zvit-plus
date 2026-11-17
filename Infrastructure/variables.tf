variable "aws_region" {
  description = "AWS region for Zvit Plus"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ssh_allowed_cidr" {
  description = "IP address allowed to connect via SSH"
  type        = string
}