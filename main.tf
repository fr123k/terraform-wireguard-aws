resource "aws_key_pair" "wireguard" {
  key_name = "wireguard-key"
  public_key = file("${path.module}/keys/aws_rsa.pub")
}

module "wireguard" {
  source = "./modules/wireguard/"

  ssh_key_id            = aws_key_pair.wireguard.id
  vpc_id                = aws_vpc.wireguard.id
  subnet                = aws_subnet.wireguard
  use_eip               = true
  wg_client_public_keys = [
    {"${cidrhost(aws_subnet.wireguard.cidr_block, 2)}/32" = "XSGknxaW7PwqiFD061TemUozeTxxafusIRr5dz2fUhw="}, # make sure these are correct
  ]
}

output "wireguard_eip" {
   value = module.wireguard.wireguards_eip
}
