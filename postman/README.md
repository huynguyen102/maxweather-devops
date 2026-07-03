# Postman / API demo

`MaxWeather.postman_collection.json` proves the OAuth2 flow end to end:

1. **Get OAuth2 token** — exchanges `client_id`/`client_secret` at the Cognito token endpoint (`client_credentials`) and stores the `access_token`.
2. **Get forecast (authorized)** — calls the API with the Bearer token; expects `200` and a `current` field.
3. **Get forecast (no token)** — calls without a token; expects `401/403`, proving the authorizer actually blocks unauthenticated requests.

No secrets are stored in the collection — the variables are empty and filled at run time from Terraform outputs.

## Variables
| Variable | Source |
|---|---|
| `base_url` | `terraform output -raw api_endpoint` |
| `token_url` | `terraform output -raw cognito_token_endpoint` |
| `client_id` | `terraform output -raw cognito_client_id` |
| `client_secret` | `terraform output -raw cognito_client_secret` |
| `scope` | `terraform output -raw cognito_scope` |

## Run in Postman
Import the collection, open **Variables**, paste the values above, then run the
three requests top to bottom (request 1 sets `access_token` for request 2).

## Run headless with newman
```sh
cd terraform
newman run ../postman/MaxWeather.postman_collection.json \
  --env-var base_url="$(terraform output -raw api_endpoint)" \
  --env-var token_url="$(terraform output -raw cognito_token_endpoint)" \
  --env-var client_id="$(terraform output -raw cognito_client_id)" \
  --env-var client_secret="$(terraform output -raw cognito_client_secret)" \
  --env-var scope="$(terraform output -raw cognito_scope)"
```
All three requests should pass — including the negative test that a missing token
is rejected. This is part of the phase 8 live verification.
