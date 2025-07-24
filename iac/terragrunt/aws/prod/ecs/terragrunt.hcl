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

#############################################################################################
inputs = {
  region                = "us-east-2"
  stage                 = "prod"
  vpc_id                = "vpc-06ba36bca6b59f95e"
  cluster_id            = "arn:aws:ecs:us-east-2:607700977843:cluster/toufikj-strapi"
  product               = "strapi"
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
  existing_load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-2:607700977843:loadbalancer/app/prod-strapi-alb/2033af0435ee9c66"
  private_subnets       = ["subnet-0f768008c6324831f", "subnet-0c0bb5df2571165a9", "subnet-0906c244cfe901a9a", "subnet-0cc2ddb32492bcc41", "subnet-0cc813dd4d76bf797"]
  security_group        = "sg-01cb7ddfd17502f04"
  existing_listener_arn = "arn:aws:elasticloadbalancing:us-east-2:607700977843:listener/app/prod-strapi-alb/2033af0435ee9c66/d82096b450d60a64"
  existing_ecs_task_execution_role_arn = "arn:aws:iam::607700977843:role/ecs-task-execution-role"
  # ssl_certificate_arn = ""
  # listener_priority     = 5  # Listener priority

  counts = 1  # Number of ECR repositories to create increse the count as needed
  names = ["toufikj-strapi"]  # Names of the ECR repositories ["metabase", "stage-strapi"]
} 

terraform {
  source = "${get_parent_terragrunt_dir("root")}}/../modules/aws/ecs"  # Correct relative path to the Strapi module
}
