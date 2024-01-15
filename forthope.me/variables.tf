variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "domain_name" {
  type        = string
  default     = "forthope.me"
  description = "Name of the domain"
}

variable "bucket_versioning" {
  type        = string
  default     = "Disabled"
  description = "Versioning for S3 bucket"
}

variable "allow_origins" {
  description = "List of origins for the API gateway"
  default     = ["https://forthope.me", "https://www.forthope.me"]
}
