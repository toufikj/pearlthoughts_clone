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
  aws_region                  = "us-east-2" # Replace with your desired AWS region
  ami_id                      = "ami-0d1b5a8c13042c939"
  instance_type               = "t3.small"
  # key_name                    = "strapi-key-1"
  subnet_id                   = "subnet-0f768008c6324831f"
  instance_name               = "strapi"
  vpc_id                      = "vpc-06ba36bca6b59f95e"
  volume_size                 = 10
  # Tags
  tags                        = local.tags
  github_username             = "toufikj"
  github_token     = get_env("GH_TOKEN")
  docker_hub_token = get_env("DOCKERHUB_TOKEN")
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/ec2"
}