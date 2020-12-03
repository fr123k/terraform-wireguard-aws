terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2"
    }
  }
}
