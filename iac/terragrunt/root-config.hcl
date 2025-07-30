locals {
  region = "us-east-2"

  version_terraform    = ">=1.8.0"
  version_terragrunt   = ">=0.59.1"
  version_provider_aws = ">=5.45.0"

  root_tags = {
    Brand = "Toufik"
  }
}


remote_state {
  backend = "s3"
  config = {
    bucket         = "toufikj-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    encrypt        = true
    region         = local.region
  }
}