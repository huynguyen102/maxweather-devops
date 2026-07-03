# OAuth2 issuer for machine-to-machine access (client_credentials grant).
# A client exchanges its id + secret at the token endpoint for a JWT access token,
# then calls the API with `Authorization: Bearer <token>`. The Lambda authorizer
# validates that JWT against this pool's JWKS.

locals {
  component          = "identity"
  domain_prefix      = var.domain_prefix != "" ? var.domain_prefix : var.name_prefix
  resource_server_id = "${var.name_prefix}-api"
  scope              = "${local.resource_server_id}/${var.scope_name}"
}

data "aws_region" "current" {}

resource "aws_cognito_user_pool" "this" {
  name = "${var.name_prefix}-users"

  tags = {
    Name      = "${var.name_prefix}-users"
    Component = local.component
  }
}

# Hosted domain that exposes the OAuth2 token endpoint.
resource "aws_cognito_user_pool_domain" "this" {
  domain       = local.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}

# Resource server defines the custom scope the API is protected by.
resource "aws_cognito_resource_server" "this" {
  identifier   = local.resource_server_id
  name         = "${var.name_prefix}-api"
  user_pool_id = aws_cognito_user_pool.this.id

  scope {
    scope_name        = var.scope_name
    scope_description = var.scope_description
  }
}

# Machine client: has a secret, uses only the client_credentials flow, and may
# request only the API scope above.
resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.name_prefix}-m2m-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret                      = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = [local.scope]
  supported_identity_providers         = ["COGNITO"]

  access_token_validity = var.access_token_validity_minutes
  token_validity_units {
    access_token = "minutes"
  }

  depends_on = [aws_cognito_resource_server.this]
}
