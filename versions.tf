data "aws_caller_identity" "current" {}

# Default region
provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.62.0"
    }
  }
}
