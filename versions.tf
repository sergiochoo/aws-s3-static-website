data "aws_caller_identity" "current" {}

# Default region
provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }

  # backend "s3" {
  #   region = var.aws_region
  #   bucket = "terraform-state-${data.aws_caller_identity.current.account_id}"
  #   key    = "terraform.tfstate"
  # }
}
