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
  backend "s3" {} # Removed remote state backend
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

#############################################################################################
inputs = {
  env                  = "prod"
  product              = "strapi"
  
  subnets              = ["subnet-0f768008c6324831f", "subnet-0c0bb5df2571165a9","subnet-0cc2ddb32492bcc41"]
  alb_sg               = dependency.rds.outputs.strapi-sg
  
  # ssl_certificate_arn = ""
  
}
dependency "rds" {
  config_path = "../rds"
  mock_outputs = {
    strapi-sg = ["sg-0ca4032c3be035ec5"]  
  }
} 

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/ecs-alb"  # Correct relative path to the Strapi module
}

