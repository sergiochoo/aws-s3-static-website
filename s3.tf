resource "aws_s3_bucket" "website" {
  bucket = var.domain_name

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_bucket_public_access_block" "s3_access_block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_object" "file" {
  for_each     = fileset(path.root, "content/**/*")
  bucket       = aws_s3_bucket.website.id
  key          = replace(each.value, "/^content//", "")
  source       = each.value
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5(each.value)
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "policy" {
  depends_on = [aws_s3_bucket_public_access_block.s3_access_block]

  bucket = aws_s3_bucket.website.id
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.website.id}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.this.id}"
                }
            }
        }
    ]
}
EOF
}
