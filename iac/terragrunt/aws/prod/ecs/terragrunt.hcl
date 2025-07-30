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
  region                = "us-east-2"
  stage                 = "prod"
  vpc_id                = "vpc-06ba36bca6b59f95e"
  cluster_id            = "arn:aws:ecs:us-east-2:607700977843:cluster/toufikj-strapi"
  product               = "strapi"
  # capacity_provider     = "FARGATE_SPOT" 
  network_mode          = "awsvpc"
  container_name        = "strapi"
  
  container_port        = 1337
  container_protocol    = "tcp"

  target_group_port     = 1337
  target_group_protocol = "HTTP"
  health_check_protocol = "HTTP"
  health_check_interval = 10
  health_check_timeout  = 8
  healthy_threshold     = 2
  unhealthy_threshold   = 3
  # domain                = "strapi.toufik.online"
  cpu                   = "1024"
  memory                = "2048"
  container_image_uri       = "607700977843.dkr.ecr.us-east-2.amazonaws.com/toufikj-strapi:latest"
  environment_variables = {
    SERVICE = "strapi"
  }
  desired_count         = 1
  existing_load_balancer_arn = dependency.alb.outputs.alb_arn
  private_subnets       = ["subnet-0f768008c6324831f", "subnet-0c0bb5df2571165a9", "subnet-0906c244cfe901a9a", "subnet-0cc2ddb32492bcc41", "subnet-0cc813dd4d76bf797"]
  security_group        = [dependency.rds.outputs.strapi-sg]
  existing_listener_arn = dependency.alb.outputs.alb_http_listener
  existing_ecs_task_execution_role_arn = "arn:aws:iam::607700977843:role/ecsTaskExecutionRole-tohid-task8"
  # ssl_certificate_arn = ""
  listener_priority     = 5  # Listener priority
} 
dependency "rds" {
  config_path = "../rds"
  mock_outputs = {
    strapi-sg = ["sg-0ca4032c3be035ec5"]
  }
} 
dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    alb_arn = "arn:aws:elasticloadbalancing:us-east-2:607700977843:loadbalancer/app/prod-strapi-alb/bcae411fce459340"
    alb_http_listener = "arn:aws:elasticloadbalancing:us-east-2:607700977843:listener/app/prod-strapi-alb/bcae411fce459340/2e4dceae69e6f284"
  }
} 

terraform {
  source = "${get_parent_terragrunt_dir("root")}}/../modules/aws/ecs"  # Correct relative path to the Strapi module
}
