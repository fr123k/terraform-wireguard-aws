locals {
  network_cidr = "10.8.0.0"
}

data "aws_route_table" "wireguard" {
  vpc_id = aws_vpc.wireguard.id
}

resource "aws_vpc" "wireguard" {
  cidr_block       = "${local.network_cidr}/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "wireguard"
  }
}

# Run into dns problems with internal AWS DNS servers during development.
# So as a quick fix define public stable once from Cloudflare.
resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["1.1.1.1", "1.0.0.1"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.wireguard.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
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
  cidr_block = "${local.network_cidr}/24"

  tags = {
    Name = "wireguard"
  }
}
