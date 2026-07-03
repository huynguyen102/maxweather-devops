<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cognito_resource_server.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_cognito_user_pool.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_token_validity_minutes"></a> [access\_token\_validity\_minutes](#input\_access\_token\_validity\_minutes) | Lifetime of issued access tokens, in minutes. | `number` | `60` | no |
| <a name="input_domain_prefix"></a> [domain\_prefix](#input\_domain\_prefix) | Cognito hosted-domain prefix (must be globally unique). Defaults to name\_prefix. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names, e.g. maxweather-prod. | `string` | n/a | yes |
| <a name="input_scope_description"></a> [scope\_description](#input\_scope\_description) | Human-readable description of the scope. | `string` | `"Read weather forecasts"` | no |
| <a name="input_scope_name"></a> [scope\_name](#input\_scope\_name) | OAuth2 scope the API requires (granted to the machine client). | `string` | `"forecast.read"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | App client ID (OAuth2 client\_id). |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | App client secret (OAuth2 client\_secret). |
| <a name="output_issuer"></a> [issuer](#output\_issuer) | Token issuer URL (JWT iss claim). |
| <a name="output_jwks_uri"></a> [jwks\_uri](#output\_jwks\_uri) | JWKS endpoint the authorizer uses to verify token signatures. |
| <a name="output_scope"></a> [scope](#output\_scope) | Full OAuth2 scope string the client requests and the authorizer expects. |
| <a name="output_token_endpoint"></a> [token\_endpoint](#output\_token\_endpoint) | OAuth2 token endpoint for the client\_credentials exchange. |
| <a name="output_user_pool_id"></a> [user\_pool\_id](#output\_user\_pool\_id) | Cognito user pool ID. |
<!-- END_TF_DOCS -->