# Custom Lambda authorizer wiring. API Gateway calls the Lambda with the request's
# Authorization header; the Lambda returns { isAuthorized } (simple response). The
# result is cached per token for authorizer_cache_ttl seconds to cut Lambda calls.

resource "aws_apigatewayv2_authorizer" "this" {
  api_id                            = aws_apigatewayv2_api.this.id
  name                              = "${var.name_prefix}-cognito-authorizer"
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = var.authorizer_invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
  identity_sources                  = ["$request.header.Authorization"]
  authorizer_result_ttl_in_seconds  = var.authorizer_cache_ttl
}

# Allow this API's authorizer to invoke the Lambda.
resource "aws_lambda_permission" "authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = var.authorizer_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.this.id}"
}
