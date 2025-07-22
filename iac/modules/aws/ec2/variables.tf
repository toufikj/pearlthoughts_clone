
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# variable "key_name" {
#   description = "SSH key name for the EC2 instance"
#   type        = string
# }

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
variable "github_username" {
  description = "GitHub username for cloning repositories"
  type        = string
}

variable "github_token" {
  description = "GitHub token for cloning private repositories"
  type        = string
  sensitive   = true
}