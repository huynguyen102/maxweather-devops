output "user_pool_id" {
  description = "Cognito user pool ID."
  value       = aws_cognito_user_pool.this.id
}

output "client_id" {
  description = "App client ID (OAuth2 client_id)."
  value       = aws_cognito_user_pool_client.this.id
}

output "client_secret" {
  description = "App client secret (OAuth2 client_secret)."
  value       = aws_cognito_user_pool_client.this.client_secret
  sensitive   = true
}

output "scope" {
  description = "Full OAuth2 scope string the client requests and the authorizer expects."
  value       = local.scope
}

output "issuer" {
  description = "Token issuer URL (JWT iss claim)."
  value       = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.this.id}"
}

output "jwks_uri" {
  description = "JWKS endpoint the authorizer uses to verify token signatures."
  value       = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/jwks.json"
}

output "token_endpoint" {
  description = "OAuth2 token endpoint for the client_credentials exchange."
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/token"
}
