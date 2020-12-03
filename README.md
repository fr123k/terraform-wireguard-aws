# terraform-wireguard-aws

```
 export TF_VAR_aws_access_key=<AWS_ACCESS_KEY_ID>
 export TF_VAR_aws_secret_key=<AWS_SECRET_ACCESS_KEY>
 export AWS_DEFAULT_REGION=eu-west-1
```

```
aws ssm put-parameter --name wireguard/wg-server-private-key --type SecureString --value $ServerPrivateKeyValue
```
