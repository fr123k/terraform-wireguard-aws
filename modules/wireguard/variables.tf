variable "ssh_key_id" {
  description = "A SSH public key ID to add to the VPN instance."
}

variable "instance_type" {
  default     = "t2.micro"
  description = "The machine type to launch, some machines may offer higher throughput for higher use cases."
}

variable "asg_min_size" {
  default     = 1
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
}

variable "asg_desired_capacity" {
  default     = 1
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
}

variable "asg_max_size" {
  default     = 1
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
}

variable "vpc_id" {
  description = "The VPC ID in which Terraform will launch the resources."
}

variable "subnet" {
  type = object({
    id = string
    cidr_block = string
  })
  description = "A subnet aws resource for the Autoscaling Group to use for launching instances. Only a single subnet."
}

variable "wg_client_public_keys" {
  # type        = map(string)
  description = "List of maps of client IPs and public keys. See Usage in README for details."
}

variable "wg_server_port" {
  default     = 51820
  description = "Port for the vpn server"
}

variable "wg_persistent_keepalive" {
  default     = 25
  description = "Persistent Keepalive - useful for helping connection stability over NATs"
}

variable "use_eip" {
  type        = bool
  default     = false
  description = "Whether to enable Elastic IP switching code in user-data on wg server startup. If true, eip_id must also be set to the ID of the Elastic IP."
}

variable "additional_security_group_ids" {
  type        = list(string)
  default     = [""]
  description = "Additional security groups if provided, default empty"
}

variable "target_group_arns" {
  type        = list(string)
  default     = null
  description = "Running a scaling group behind an LB requires this variable, default null means it won't be included if not set"
}

variable "env" {
  default     = "prod"
  description = "The name of environment for WireGuard. Used to differentiate multiple deployments"
}

variable "mailjet_api_credentials" {
  default = ""
  description = "The mailjet api credentials in the form API_KEY:SECRET_KEY"
}

variable "vpn_enabled_ssh" {
  default = "true"
  type = bool
  description = "If true the ssh port restricted to the wireguard network range. Otherwise its open for public (0.0.0.0/0)."
}
