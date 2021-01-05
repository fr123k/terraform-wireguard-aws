resource "aws_key_pair" "wireguard" {
  key_name   = "wireguard-key"
  public_key = file("${path.module}/keys/wireguard.pem.pub")
}

module "wireguard" {
  source = "./modules/wireguard/"

  ssh_key_id              = aws_key_pair.wireguard.id
  vpc_id                  = aws_vpc.wireguard.id
  subnet                  = aws_subnet.wireguard
  use_eip                 = true
  mailjet_api_credentials = var.mailjet_api_credentials
  vpn_enabled_ssh         = var.vpn_enabled_ssh
  wg_client_public_keys = [
    { "${cidrhost(aws_subnet.wireguard.cidr_block, 3)}/32" = var.client_public_key }, # make sure these are correct
  ]
}
