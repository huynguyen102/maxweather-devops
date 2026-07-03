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
| [aws_ecr_lifecycle_policy.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | IMMUTABLE prevents overwriting a pushed tag (CI must use unique tags, e.g. git SHA); MUTABLE allows it. | `string` | `"IMMUTABLE"` | no |
| <a name="input_max_image_count"></a> [max\_image\_count](#input\_max\_image\_count) | Number of most-recent images to keep; older ones are expired by the lifecycle policy. | `number` | `10` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names, e.g. maxweather-prod. | `string` | n/a | yes |
| <a name="input_scan_on_push"></a> [scan\_on\_push](#input\_scan\_on\_push) | Scan images for known CVEs automatically on push. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_repository_arn"></a> [repository\_arn](#output\_repository\_arn) | ARN of the repository (for IAM policies). |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the repository. |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | Repository URL to push to (CI) and pull from (EKS). |
<!-- END_TF_DOCS -->