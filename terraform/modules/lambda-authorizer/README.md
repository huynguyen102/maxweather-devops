<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_audience"></a> [audience](#input\_audience) | Expected client\_id in the token (Cognito app client ID). | `string` | n/a | yes |
| <a name="input_issuer"></a> [issuer](#input\_issuer) | Expected JWT issuer (Cognito user pool issuer URL). | `string` | n/a | yes |
| <a name="input_jwks_uri"></a> [jwks\_uri](#input\_jwks\_uri) | JWKS endpoint used to verify token signatures. | `string` | n/a | yes |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention for the authorizer function. | `number` | `14` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names, e.g. maxweather-prod. | `string` | n/a | yes |
| <a name="input_required_scope"></a> [required\_scope](#input\_required\_scope) | OAuth2 scope the token must carry to be authorized. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the authorizer Lambda function. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the authorizer Lambda function. |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | Invoke ARN used by the API Gateway authorizer integration. |
<!-- END_TF_DOCS -->