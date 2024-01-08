output "cloudfront_url" {
  description = "Website URL (HTTPS)"
  value       = module.s3_website.cloudfront_url
}

output "website_url" {
  value = module.s3_website.website_url
}
