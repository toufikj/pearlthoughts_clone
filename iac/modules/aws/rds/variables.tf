variable "environment" {
  type = string
  
}

variable "identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default     = "demodb"
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "16.3-R2"
}

variable "instance_class" {
  description = "The instance class to use for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage for the database"
  type        = number
  default     = 5
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "demodb"
}

variable "username" {
  description = "The database username"
  type        = string
  default     = "user"
}
variable "password" {
  description = "The database password"
  type        = string
}

variable "port" {
  description = "The port to connect to the database"
  type        = string
  default     = "5432"
}



variable "subnet_ids" {
  description = "The subnet IDs for the RDS instance"
  type        = list(string)
}


variable "tags" {
  description = "Tags for the resource"
  type        = map(string)
  default     = {
    Owner       = "user"
    Environment = "dev"
  }
}

# variable "family" {
#   description = "The family of the DB parameter group"
#   type        = string
#   default     = "postgres16"
# }

# variable "major_engine_version" {
#   description = "The major version of the engine"
#   type        = string
#   default     = "16.3"
# }

variable "deletion_protection" {
  description = "Enable deletion protection for the database"
  type        = bool
  default     = true
}


variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  # default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "The vpc for security group to use"
  type        = string
}


variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
}



