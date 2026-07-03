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
| [aws_apigatewayv2_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_authorizer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_authorizer) | resource |
| [aws_apigatewayv2_integration.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_log_group.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_permission.authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_authorizer_cache_ttl"></a> [authorizer\_cache\_ttl](#input\_authorizer\_cache\_ttl) | Seconds to cache an authorizer result per token, reducing Lambda calls (0 disables). | `number` | `300` | no |
| <a name="input_authorizer_function_name"></a> [authorizer\_function\_name](#input\_authorizer\_function\_name) | Name of the Lambda authorizer (for the invoke permission). | `string` | n/a | yes |
| <a name="input_authorizer_invoke_arn"></a> [authorizer\_invoke\_arn](#input\_authorizer\_invoke\_arn) | Invoke ARN of the Lambda authorizer. | `string` | n/a | yes |
| <a name="input_backend_url"></a> [backend\_url](#input\_backend\_url) | Backend the API proxies to — the Nginx Ingress NLB URL. Set after the cluster is up (phase 8). | `string` | `""` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch retention for API access logs. | `number` | `14` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names, e.g. maxweather-prod. | `string` | n/a | yes |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | API stage name. $default gives a stageless invoke URL. | `string` | `"$default"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | Base invoke URL of the API. |
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | API Gateway API ID. |
<!-- END_TF_DOCS -->