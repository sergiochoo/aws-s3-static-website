variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "domain_name" {
  type        = string
  default     = "forthope.me"
  description = "Name of the domain"
}

variable "tags" {
  default = {
    managedBy = "Terraform"
  }
}

variable "allow_origins" {
  description = "List of origins for the API gateway"
  default     = []
}

locals {
  content_types = {
    ".css" : "text/css",
    ".html" : "text/html",
    ".ico" : "image/vnd.microsoft.icon"
    ".jpeg" : "image/jpeg"
    ".jpg" : "image/jpeg"
    ".js" : "text/javascript"
    ".mp4" : "video/mp4"
    ".png" : "image/png"
    ".svg" : "image/svg+xml"
    ".wasm" : "application/wasm"
    ".zip" : "application/zip"
  }
}

variable "bucket_versioning" {
  type        = string
  default     = "Disabled"
  description = "Versioning for S3 bucket"
}
