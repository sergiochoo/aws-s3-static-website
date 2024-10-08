# IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "terraform_lambda_func_Role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
  })
}

# IAM Policy for Lambda function
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_lambda_func_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:UpdateItem",
            "dynamodb:GetItem",
            "dynamodb:PutItem"
          ],
          "Resource" : "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/visitor_count_ddb"
        },
      ]
  })
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# # Archive Python code into a zip file
# data "archive_file" "zip_the_python_code" {
#   type        = "zip"
#   source_dir  = "${path.module}/misc/lambda/"
#   output_path = "${path.module}/misc/lambda/lambda_function.zip"
# }

# Lambda Function
resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "${path.module}/misc/lambda/lambda_function.zip"
  function_name = "terraform_lambda_func"
  role          = aws_iam_role.lambda_role.arn
  handler       = "counter.lambda_handler"
  runtime       = "python3.10"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      databaseName = "visitor_count_ddb"
    }
  }
  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "visitor_count_log_group"
  retention_in_days = 3
  tags              = var.tags
}

# API Gateway API
resource "aws_apigatewayv2_api" "lambda" {
  name          = "visitor_count_CRC"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = var.allow_origins
  }
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = var.tags
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "terraform_lambda_func" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.terraform_lambda_func.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# API Gateway Route
resource "aws_apigatewayv2_route" "terraform_lambda_func" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "ANY /terraform_lambda_func"
  target    = "integrations/${aws_apigatewayv2_integration.terraform_lambda_func.id}"
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

# DynamoDB Table
resource "aws_dynamodb_table" "visitor_count_ddb" {
  name           = "visitor_count_ddb"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "visitor_count"
    type = "N"
  }

  global_secondary_index {
    name            = "visitor_count_index"
    hash_key        = "visitor_count"
    projection_type = "ALL"
    read_capacity   = 10
    write_capacity  = 10
  }

  tags = var.tags
}

# DynamoDB Table Item
resource "aws_dynamodb_table_item" "visitor_count_ddb" {
  table_name = aws_dynamodb_table.visitor_count_ddb.name
  hash_key   = aws_dynamodb_table.visitor_count_ddb.hash_key

  item = <<ITEM
{
  "id": {"S": "visitor_count"},
  "visitor_count": {"N": "1"}
}
ITEM
  lifecycle {
    ignore_changes = all
  }
}
