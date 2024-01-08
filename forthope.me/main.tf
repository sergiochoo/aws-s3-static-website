provider "aws" {
  region = var.aws_region
}

module "s3_website" {
  source            = "../"
  domain_name       = var.domain_name
  bucket_versioning = var.bucket_versioning
}
