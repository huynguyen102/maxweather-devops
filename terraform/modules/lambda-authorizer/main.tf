# Custom Lambda authorizer for API Gateway. API Gateway invokes this function on
# each request; it verifies the Cognito JWT and returns allow/deny. The source is
# a single dependency-free file, zipped in place by archive_file.

locals {
  component     = "auth"
  function_name = "${var.name_prefix}-authorizer"
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/authorizer.zip"
}

resource "aws_iam_role" "this" {
  name = "${local.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Component = local.component }
}

# Least privilege: only the managed policy that lets the function write its own logs.
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name      = "/aws/lambda/${local.function_name}"
    Component = local.component
  }
}

resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  role             = aws_iam_role.this.arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  timeout          = 5

  environment {
    variables = {
      ISSUER         = var.issuer
      JWKS_URI       = var.jwks_uri
      AUDIENCE       = var.audience
      REQUIRED_SCOPE = var.required_scope
    }
  }

  tags = {
    Name      = local.function_name
    Component = local.component
  }

  depends_on = [aws_cloudwatch_log_group.this]
}
