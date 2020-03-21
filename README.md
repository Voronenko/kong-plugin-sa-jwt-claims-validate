[![Build Status][badge-travis-image]][badge-travis-url]

sa-jwt-claims-validate
======================

Plugin functionality:

supposed to work in combination with kong's built-in jwt plugin.
Built-in plugin is responsible for validation of the jwt token signature and validity/expiration claims.

This plugin - exposes plugin claims to upstream services via headers,
additionally it can be used as a security filter to enforce presence of
specified claims and checking they are matching expected values.

## Usage

### Parameters

| Parameter | Default  | Required | description |
| --- | --- | --- | --- |
| `name` || true | plugin name, has to be `sa-jwt-claims-validate` |
| `config.log_level` |"info"| false | Tunes level of info provvided for troubleshouting |
| `config.option_expose_headers` |true| false | If set to true all jwt token data are decoded and exposed to upstream as headers.  |
| `config.exposed_headers` |"all"| false | Comma separated list of claims to be exposed to upstream as headers or all |
| `config.validate_iss` |""| false | If set, iss claim is compared to value |
| `config.validate_sub` |""| false | If set, sub claim is compared to value |
| `config.validate_aud` |""| false | If set, aud claim is compared to value |
| `config.validate_azp` |""| false | If set, azp claim is compared to value |
| `config.validate_client_id` |""| false | If set, client_id claim is compared to value |
| `config.validate_dynamic1` |""| false | If set in form claim==>value , validates if claim equals specified value |
| `config.validate_dynamic2` |""| false | If set in form claim==>value , validates if claim equals specified value |
| `config.validate_dynamic3` |""| false | If set in form claim==>value , validates if claim equals specified value |
| `config.claims` |nil| false | If set as map form claim:value , validates if claims set matches specified values. Number of claims is not limited |

### Output

Plugin is able to expose all or agreed claims in form of headers `x-sa-jwt-claim-CLAIMNAME`. In case if claim contains object, you will get json serialized values, in other case you will get string.

Separately outputs original authorization token in header `x-sa-jwt-token`


## (A) expose jwt token info to upstream services

For incoming token (location configurable)
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlF6bEZOak5CUmtZNVJqY3lOVVpCUmpJMU5qRkJOMFl4T0VNMVJFSXhNelU0TVVJeU5qa3dSUSJ9.eyJpc3MiOiJodHRwczovL3Zvcm9uZW5rby5hdXRoMC5jb20vIiwic3ViIjoiUjQ3N3pkMGRoRDBIcTNDbk5JRWdFNjc3bndib1lENXVAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vaW1wbGljaXRncmFudC5hdXRoMC52b3JvbmVua28ubmV0IiwiaWF0IjoxNTc1NTgzNTM2LCJleHAiOjE1NzU2Njk5MzYsImF6cCI6IlI0Nzd6ZDBkaEQwSHEzQ25OSUVnRTY3N253Ym9ZRDV1IiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.aIx7LnT7aFPxmK4wCXxxGhEKrxPsGlZ3azEFykynkf6hfyb-4zCXlrqvxNjB9pk_PO8MxmKRJeoRsHLmNOvVls3tE90GQNa6DrqyWuO5PxZetkPyR56o5axt4PddZlop-mukiMYrZF2bP_gdRBZnhR2OJ4vU3qG6Rvs2k-J65tbb2oUERWps7KDC2FeTbV2bc09JtH25StNfYyHOPUR1MiDSKZbZqH3Z0bZUFHN1Ac7jznU3xUV8yEPTy7hQwOWUK5CxUSvd_s4RlTLKsHdAQWWxoDPRvxldwPXtxc7n13hwQPslJNR1ScbREcgJo4zPOcVM_uzTk1ygczLJCzvdsA
```

which is equivalent of jwt token

header
```
{
  "typ": "JWT",
  "alg": "RS256",
  "kid": "QzlFNjNBRkY5RjcyNUZBRjI1NjFBN0YxOEM1REIxMzU4MUIyNjkwRQ"
}
```

payload
```
{
  "iss": "https://voronenko.auth0.com/",
  "sub": "R477zd0dhD0Hq3CnNIEgE677nwboYD5u@clients",
  "aud": "https://implicitgrant.auth0.voronenko.net",
  "iat": 1575583536,
  "exp": 1575669936,
  "azp": "R477zd0dhD0Hq3CnNIEgE677nwboYD5u",
  "gty": "client-credentials"
}
```


it will expose following headers to upstream service:

```
"x-sa-jwt-claim-gty":"client-credentials",
"x-sa-jwt-claim-exp":"1575669936",
"x-sa-jwt-claim-azp":"R477zd0dhD0Hq3CnNIEgE677nwboYD5u"
"x-sa-jwt-claim-iat":"1575583536"
"x-sa-jwt-token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlF6bEZOak5CUmtZNVJqY3lOVVpCUmpJMU5qRkJOMFl4T0VNMVJFSXhNelU0TVVJeU5qa3dSUSJ9.eyJpc3MiOiJodHRwczovL3Zvcm9uZW5rby5hdXRoMC5jb20vIiwic3ViIjoiUjQ3N3pkMGRoRDBIcTNDbk5JRWdFNjc3bndib1lENXVAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vaW1wbGljaXRncmFudC5hdXRoMC52b3JvbmVua28ubmV0IiwiaWF0IjoxNTc1NTgzNTM2LCJleHAiOjE1NzU2Njk5MzYsImF6cCI6IlI0Nzd6ZDBkaEQwSHEzQ25OSUVnRTY3N253Ym9ZRDV1IiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.aIx7LnT7aFPxmK4wCXxxGhEKrxPsGlZ3azEFykynkf6hfyb-4zCXlrqvxNjB9pk_PO8MxmKRJeoRsHLmNOvVls3tE90GQNa6DrqyWuO5PxZetkPyR56o5axt4PddZlop-mukiMYrZF2bP_gdRBZnhR2OJ4vU3qG6Rvs2k-J65tbb2oUERWps7KDC2FeTbV2bc09JtH25StNfYyHOPUR1MiDSKZbZqH3Z0bZUFHN1Ac7jznU3xUV8yEPTy7hQwOWUK5CxUSvd_s4RlTLKsHdAQWWxoDPRvxldwPXtxc7n13hwQPslJNR1ScbREcgJo4zPOcVM_uzTk1ygczLJCzvdsA"
"x-sa-jwt-claim-iss":"https:\/\/voronenko.auth0.com\/"
"x-sa-jwt-claim-sub":"R477zd0dhD0Hq3CnNIEgE677nwboYD5u@clients"
"x-sa-jwt-claim-aud":"https:\/\/implicitgrant.auth0.voronenko.net"}
```


## (B) validate jwt token claims before passing info to upstream services



### Activate sa-jwt-claims-validate plugin for service

```
curl -X POST \
     --url {{kong}}/services/{{ m2mservice_name }}/plugins/ \
     -d '{
       "name": "jwt-claims-validate",
       "config": {
         "claims": {
             "iss": "https://voronenko.auth0.com/",
             "aud": "https://implicitgrant.auth0.voronenko.net"
         }
       }
     }'
```

```
curl -X POST \
     --url {{kong}}/services/{{ m2mservice_name }}/plugins/ \
     --data 'name=jwt-claims-validate' \
     --data 'validate_iss=https://voronenko.auth0.com/' \
     --data 'validate_aud=https://implicitgrant.auth0.voronenko.net'
```


## Development
This workflow is designed to work with the
[`kong-pongo`](https://github.com/Kong/kong-pongo) development environment.
Check Makefile and travis file.

Please check out those repos `README` files for usage instructions.

[badge-travis-url]: https://travis-ci.com/voronenko/kong-plugin-sa-jwt-claims-validate/branches
[badge-travis-image]: https://travis-ci.com/voronenko/kong-plugin-sa-jwt-claims-validate.svg?branch=master
