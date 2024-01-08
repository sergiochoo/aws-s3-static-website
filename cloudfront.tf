resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  aliases             = [var.domain_name, "www.${var.domain_name}"]
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_domain_name # aws_s3_bucket_website_configuration.hosting.website_endpoint
    origin_id                = aws_s3_bucket.website.id                 #bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id

    # custom_origin_config {
    #   http_port                = 80
    #   https_port               = 443
    #   origin_keepalive_timeout = 5
    #   origin_protocol_policy   = "http-only"
    #   origin_read_timeout      = 30
    #   origin_ssl_protocols = [
    #     "TLSv1.2",
    #   ]
    # }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.this.arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.website.id # bucket_regional_domain_name
  }

  tags = var.tags
}
