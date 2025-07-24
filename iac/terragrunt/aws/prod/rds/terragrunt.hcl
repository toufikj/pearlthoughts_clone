include "root" {
  path   = find_in_parent_folders("root-config.hcl")
  expose = true
}

include "stage" {
  path   = find_in_parent_folders("prod.hcl")
  expose = true
}

locals {
  # merge tags
  local_tags = {
    "Name" = "strapi"
  }

  tags = merge(include.root.locals.root_tags, include.stage.locals.tags, local.local_tags)
}

generate "provider_global" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  # backend "s3" {} # Removed remote state backend
  required_version = "${include.root.locals.version_terraform}"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "${include.root.locals.version_provider_aws}"
    }
  }
}

provider "aws" {
  region = "${include.root.locals.region}"
}
EOF
}



########################
inputs = {
         environment               = "prod"
        identifier                = "toufikj-strapi-rds"
        engine                    = "postgres"
        engine_version            = "16.3"
        instance_class            = "db.t3.micro"
        allocated_storage         = 5
        db_name                   = "strapi_db"
        username                  = "strapi"
        password                  = get_env("DB_PASS")
        port                      = "5432"
        subnet_ids                = ["subnet-0f768008c6324831f", "subnet-0c0bb5df2571165a9","subnet-0906c244cfe901a9a"]
        tags                      = {
          Environment = "prod"
        }
        # family                    = "postgres16"
        # major_engine_version       = "16.3"
        deletion_protection        = false

        vpc_id                      = "vpc-06ba36bca6b59f95e"
        allowed_ssh_cidr_blocks    = ["0.0.0.0/0"]  # Adjust as necessary for security
        ingress_rules = [
          {
            from_port = 5432
            to_port   = 5432
            protocol  = "tcp"
            
          },
          {
            from_port = 1337
            to_port   = 1337
            protocol  = "tcp"
            
          },
          {
            from_port = 80
            to_port   = 80
            protocol  = "tcp"
            
          }
        
        ]

        egress_rules = [
          {
            from_port = 0
            to_port   = 0
            protocol  = "-1"
            
          }
        ]
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/rds"  # Correct relative path to the RDS module
}