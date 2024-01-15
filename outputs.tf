output "cloudfront_url" {
  description = "Cloudfront URL (HTTPS)"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "website_url" {
  description = "Website URL (HTTPS)"
  value       = "www.${var.domain_name}"
}

output "base_url" {
  description = "Base URL for API Gateway stage"
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}
