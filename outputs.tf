output "cloudfront_url" {
  description = "Website URL (HTTPS)"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "website_url" {
  value = "www.${var.domain_name}"
}
