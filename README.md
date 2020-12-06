# terraform-wireguard-aws

# AWS Authentication

## With AWS Cli

### Prerequisties

* awscli

Installation for MacOs
```
brew install awscli
```

### Access/Secret Keys

To setup the access keys for terraform either use the aws cli and run the following command
it will ask for the access key and secret key id and store them in a file `~/.aws/credentials`.
Those one then also picked up by the terraform aws provider.

```
aws configure
```

## Environment Variables

The values of the following defined environment variables will work for the awscli and the terraform
aws provider and if you put leave a space before the command then they also not appear in the bash
history.

```
 export AWS_ACCESS_KEY_ID=******
 export AWS_SECRET_ACCESS_KEY=******
 export AWS_DEFAULT_REGION=eu-west-1 
```


# Terraform Wireguard

## Prerequisites

* add your ssh rsa public key to the `keys/aws_rsa.pub` key

## Wireguard Keys

- Install the WireGuard tools for your OS: https://www.wireguard.com/install/
- Generate a key pair for the clients
  - `wg genkey | tee client1-privatekey | wg pubkey > client1-publickey`
- Add the desired client ip address and client public key to the variable `wg_client_public_keys` in the 
  `main.tf` file.
  ```
    module "wireguard" {
        source = "./modules/wireguard/"

        ssh_key_id            = aws_key_pair.wireguard.id
        vpc_id                = aws_vpc.wireguard.id
        subnet                = aws_subnet.wireguard
        wg_client_public_keys = [
            {"10.8.0.2/32" = "XSGknxa................................fUhw="},
            {"10.8.0.3/32" = "W.........................................E="},
        ]
    }
  ```
  `10.8.0.2/32` is the desired ip address for the client and the value `XSGknxa................................fUhw=`
  is the generated client public key from above

## Infrastructure

The following command will create the wireguard server virtual machine and all other needed
resources like an aws_key_pair and an aws_vpc and so on.
```
terraform apply
```

# Todos

* store the wireguard server public key outside of the VM (github/s3) so that the client can fetch it
* configure the client ips and publickeys outisde of terraform so that a change doesn't need a full recreation of the wireguard VM
  only a restart of the wireguard systemd service would be needed.
