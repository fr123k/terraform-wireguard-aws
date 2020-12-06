locals {
  network_cidr = "10.8.0.0/16"
}

data "aws_route_table" "wireguard" {
  vpc_id = aws_vpc.wireguard.id
}

resource "aws_vpc" "wireguard" {
  cidr_block       = local.network_cidr
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "wireguard"
  }
}

# without an intener gateway all the VM in this vpc has no internet connection
resource "aws_internet_gateway" "wireguard" {
  vpc_id = aws_vpc.wireguard.id

  tags = {
    Name = "wireguard"
  }
}

# adding the internet gateway as default gateway to the aws_vpc.wirecard vpc resource
resource "aws_route" "wireguard" {
  route_table_id         = data.aws_route_table.wireguard.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wireguard.id
}

resource "aws_subnet" "wireguard" {
  vpc_id     = aws_vpc.wireguard.id
  cidr_block = "10.8.0.0/24"

  tags = {
    Name = "wireguard"
  }
}
