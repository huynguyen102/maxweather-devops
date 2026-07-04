# HTTP API that fronts the platform. Assumption #3 permits a proxy integration, so
# the API forwards every request to the backend (the Nginx Ingress NLB) rather than
# modelling each resource. Access logs go to CloudWatch.

locals {
  component = "api"
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${var.name_prefix}-api"
  protocol_type = "HTTP"

  tags = {
    Name      = "${var.name_prefix}-api"
    Component = local.component
  }
}

# HTTP_PROXY forwards the matched path to the backend. {proxy} carries the path
# captured by the route below (e.g. /forecast).
#
# Gated on backend_url: API Gateway rejects an integration without a valid HTTP
# endpoint, and the backend (the Nginx Ingress NLB) does not exist until the
# cluster is up. So the first apply creates the API/authorizer/stage; the second
# apply — once backend_url is the NLB hostname — creates the integration + route.
resource "aws_apigatewayv2_integration" "backend" {
  count = var.backend_url != "" ? 1 : 0

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "${var.backend_url}/{proxy}"
  payload_format_version = "1.0"
}

# Catch-all route, protected by the custom authorizer.
resource "aws_apigatewayv2_route" "proxy" {
  count = var.backend_url != "" ? 1 : 0

  api_id             = aws_apigatewayv2_api.this.id
  route_key          = "ANY /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.backend[0].id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.this.id
}

resource "aws_cloudwatch_log_group" "access" {
  name              = "/aws/apigateway/${var.name_prefix}-api"
  retention_in_days = var.log_retention_days

  tags = {
    Name      = "/aws/apigateway/${var.name_prefix}-api"
    Component = local.component
  }
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access.arn
    format = jsonencode({
      requestId       = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      routeKey        = "$context.routeKey"
      status          = "$context.status"
      protocol        = "$context.protocol"
      responseLength  = "$context.responseLength"
      authorizerError = "$context.authorizer.error"
    })
  }

  tags = {
    Name      = "${var.name_prefix}-api-stage"
    Component = local.component
  }
}
