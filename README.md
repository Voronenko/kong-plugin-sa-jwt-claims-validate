[![Build Status][badge-travis-image]][badge-travis-url]

sa-jwt-claims-validate
======================

Plugin functionality: 

## (A) expose jwt token info to upstream services

For incoming token (location configurable)
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6IlF6bEZOak5CUmtZNVJqY3lOVVpCUmpJMU5qRkJOMFl4T0VNMVJFSXhNelU0TVVJeU5qa3dSUSJ9.eyJpc3MiOiJodHRwczovL3Zvcm9uZW5rby5hdXRoMC5jb20vIiwic3ViIjoiUjQ3N3pkMGRoRDBIcTNDbk5JRWdFNjc3bndib1lENXVAY2xpZW50cyIsImF1ZCI6Imh0dHBzOi8vaW1wbGljaXRncmFudC5hdXRoMC52b3JvbmVua28ubmV0IiwiaWF0IjoxNTc1NTgzNTM2LCJleHAiOjE1NzU2Njk5MzYsImF6cCI6IlI0Nzd6ZDBkaEQwSHEzQ25OSUVnRTY3N253Ym9ZRDV1IiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.aIx7LnT7aFPxmK4wCXxxGhEKrxPsGlZ3azEFykynkf6hfyb-4zCXlrqvxNjB9pk_PO8MxmKRJeoRsHLmNOvVls3tE90GQNa6DrqyWuO5PxZetkPyR56o5axt4PddZlop-mukiMYrZF2bP_gdRBZnhR2OJ4vU3qG6Rvs2k-J65tbb2oUERWps7KDC2FeTbV2bc09JtH25StNfYyHOPUR1MiDSKZbZqH3Z0bZUFHN1Ac7jznU3xUV8yEPTy7hQwOWUK5CxUSvd_s4RlTLKsHdAQWWxoDPRvxldwPXtxc7n13hwQPslJNR1ScbREcgJo4zPOcVM_uzTk1ygczLJCzvdsA
```

which is equialent of jwt token

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


## Development
This workflow is designed to work with the
[`kong-pongo`](https://github.com/Kong/kong-pongo) and
[`kong-vagrant`](https://github.com/Kong/kong-vagrant) development environments.

Please check out those repos `README` files for usage instructions.

[badge-travis-url]: https://travis-ci.com/voronenko/kong-plugin-sa-jwt-claims-validate/branches
[badge-travis-image]: https://travis-ci.com/voronenko/kong-plugin-sa-jwt-claims-validate.svg?branch=master
