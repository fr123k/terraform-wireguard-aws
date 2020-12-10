variable "mailjet_api_credentials" {
  default     = ""
  description = "The mailjet api credentials in the form API_KEY:SECRET_KEY"
}

variable "client_public_key" {
  default     = "XSGknxaW7PwqiFD061TemUozeTxxafusIRr5dz2fUhw="
  description = "The wireguard client public key."
}

variable "vpn_enabled_ssh" {
  default = "true"
  type = bool
  description = "If true the ssh port restricted to the wireguard network range. Otherwise its open for public (0.0.0.0/0)."
}

output "wireguard_eips" {
  value = module.wireguard.wireguards_eip
  description = "The list of elastic ip addresses assigned to the wireguard virtual machines."
}
