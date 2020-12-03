resource "aws_key_pair" "wireguard" {
  key_name = "wireguard-key"
  public_key = file("${path.module}/aws_rsa.pub")
}

resource "aws_vpc" "wireguard" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support = true

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

# resource "aws_route_table" "wireguard" {
#   vpc_id = aws_vpc.wireguard.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.wireguard.id
#   }

#   tags = {
#     Name = "wireguard"
#   }
# }

data "aws_route_table" "wireguard" {
  vpc_id = aws_vpc.wireguard.id
}

resource "aws_route" "wireguard" {
  route_table_id              = data.aws_route_table.wireguard.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.wireguard.id
}

resource "aws_subnet" "wireguard" {
#   vpc_id = "vpc-4d4bf62a"
  vpc_id     = aws_vpc.wireguard.id
#   cidr_block = "172.31.48.0/20"
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "wireguard"
  }
}

module "wireguard" {
  source = "./modules/wireguard/"

  ssh_key_id            = aws_key_pair.wireguard.id
  vpc_id                = aws_vpc.wireguard.id
#   vpc_id                = "vpc-4d4bf62a"
  subnet_ids            = [aws_subnet.wireguard.id]
  use_eip               = true
#   wg_server_net         = "172.31.48.1/24" # client IPs MUST exist in this net
#   wg_client_public_keys = [
#     {"172.31.48.2/32" = "QFX/DXxUv56mleCJbfYyhN/KnLCrgp7Fq2fyVOk/FWU="}, # make sure these are correct
#     {"172.31.48.3/32" = "+IEmKgaapYosHeehKW8MCcU65Tf5e4aXIvXGdcUlI0Q="}, # wireguard is sensitive
#     {"172.31.48.4/32" = "WO0tKrpUWlqbl/xWv6riJIXipiMfAEKi51qvHFUU30E="}, # to bad configuration
  wg_server_net         = "192.168.2.1/24" # client IPs MUST exist in this net
  wg_client_public_keys = [
    {"192.168.2.2/32" = "QFX/DXxUv56mleCJbfYyhN/KnLCrgp7Fq2fyVOk/FWU="}, # make sure these are correct
    {"192.168.2.3/32" = "+IEmKgaapYosHeehKW8MCcU65Tf5e4aXIvXGdcUlI0Q="}, # wireguard is sensitive
    {"192.168.2.4/32" = "WO0tKrpUWlqbl/xWv6riJIXipiMfAEKi51qvHFUU30E="}, # to bad configuration
  ]
}
