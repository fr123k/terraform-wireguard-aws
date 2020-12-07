variable "mailjet_api_credentials" {
  default     = ""
  description = "The mailjet api credentials in the form API_KEY:SECRET_KEY"
}

variable "client_public_key" {
  default     = "XSGknxaW7PwqiFD061TemUozeTxxafusIRr5dz2fUhw="
  description = "The wireguard client public key."
}

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
  wg_client_public_keys = [
    { "${cidrhost(aws_subnet.wireguard.cidr_block, 2)}/32" = var.client_public_key }, # make sure these are correct
  ]
}

output "wireguard_eip" {
  value = module.wireguard.wireguards_eip
}
