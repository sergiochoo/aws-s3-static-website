### Architecture
![alt text](https://raw.githubusercontent.com/sergiochoo/aws-s3-static-website/main/misc/architecture.avif)

[![.github/workflows/deploy.yml](https://github.com/sergiochoo/aws-s3-static-website/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/sergiochoo/aws-s3-static-website/actions/workflows/deploy.yml)

### CI/CD with GitHub actions setup:
Replace `123456789012` with your actual AWS Account ID
Export your AWS account id as a shell variable for later use
```
export accountid=123456789012
```

Create S3 bucket to store the Terraform state. You can choose a different region
```bash
aws s3 mb s3://terraform-state1-${accountid} --region us-east-1
```

Create AWS IAM user with username 'GithubActions' using a designated profile
```bash
aws iam create-user --user-name GithubActions
```

Create AWS IAM group with the name 'DeployS3Site' using the same AWS profile
```bash
aws iam create-group --group-name DeployS3Site
```

Create AWS IAM policy named 'DeployS3SitePolicy' using the policy located in 'file://misc/policy.json'. This policy should define permissions necessary for operations

```bash
aws iam create-policy --policy-name DeployS3SitePolicy --policy-document file://misc/policy.json
```

Attach the policy created above to the group 'DeployS3Site'. The policy ARN is derived from your AWS account id and policy name

```bash
aws iam attach-group-policy --policy-arn arn:aws:iam::${accountid}:policy/DeployS3SitePolicy --group-name DeployS3Site
```

Add the previously created user 'GithubActions' to the group 'DeployS3Site', giving the user all permissions defined in the attached policy
```bash
aws iam add-user-to-group --user-name GithubActions --group-name DeployS3Site
```

Create AWS Access Key for the IAM user 'GithubActions' which can be used for authenticating via CLI, SDKs etc.
```
aws iam create-access-key --user-name GithubActions
```

Add the following secrets into your repository settings:
```bash
ACCOUNT_ID
AWS_ACCESS_KEY_ID
AWS_REGION
AWS_SECRET_ACCESS_KEY
DISTRIBUTION_ID - (you can find it in the AWS console)
```

Add the following environment variables into your repository settings:
```bash
SITE_NAME - (forthope.me in my case)
```

<!-- BEGIN_TF_DOCS -->
### Module requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.31.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.31.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_website"></a> [s3\_website](#module\_s3\_website) | ../ | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.www](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.s3_bucket_ownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.s3_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.hosting](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_object.file](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_bucket_versioning"></a> [bucket\_versioning](#input\_bucket\_versioning) | Versioning for S3 bucket | `string` | `"Disabled"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the domain | `string` | `"example.com"` | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map` | <pre>{<br>  "managedBy": "Terraform"<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_url"></a> [cloudfront\_url](#output\_cloudfront\_url) | Cloudfront URL |
| <a name="output_website_url"></a> [website\_url](#output\_website\_url) | Website URL (HTTPS) |
<!-- END_TF_DOCS -->
