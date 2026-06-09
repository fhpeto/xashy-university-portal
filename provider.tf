terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"

    }
  }

  required_version = ">=1.12.2"

  backend "s3" {
    bucket       = "xashy-uni-portal-backend"
    key          = "dev/xashy-university-portal.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

}

