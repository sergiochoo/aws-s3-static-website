output "cloudfront_url" {
  description = "Cloudfront URL (HTTPS)"
  value       = module.s3_website.cloudfront_url
}

output "website_url" {
  description = "Website URL (HTTPS)"
  value       = module.s3_website.website_url
}

output "base_url" {
  description = "Base URL for API Gateway stage"
  value       = module.s3_website.base_url
}
