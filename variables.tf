variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {
  default = "eu-west-1"
}

# explicit map
# variable "web_server_amis" {
#   type = map
# }

#multiline string
variable "long_string" {
  type = string
  default = <<END
Multil ine string
example in terraform
!
END
}

# explicit list
variable "sizes" {
  type = list
  default = ["small", "medium", "large"]
}

# explicit map
variable "map" {
  type = map
  default = {
      "eu-west-1" = "ami-0aef57767f5404a3c"
  }
}
