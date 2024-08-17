terraform {
  backend "s3" {
    bucket = "terraform-states-zg"
    key    = "serverless-website-project/terraform_serverless-project-website.tfstate"
    region = "us-east-1"
  }
  required_version = "> 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = terraform.workspace
      Owner       = "Stephane Zang Bengono"
      Project     = "Serverless Website Project"
      Terraform   = "true"
    }
  }
}