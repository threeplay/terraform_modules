provider "aws" {
  region = var.region
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr_block" {
  description = "main vpc's cidr block"
  type = string
}

variable "private_subnets" {
  description = "a list of subnets to create in the vpc (main_subnets[..])"
  type = list(string)
}

variable "public_subnets" {
  description = "a list of subnets to create in the vpc (main_subnets[..])"
  type = list(string)
}

variable "public_ingress" {
  type = map(object({
    from = number,
    to = number,
    protocol = string
  }))
  description = "Ingress rules for public subnets"
  default = {
    ssh = {
      protocol = "tcp",
      from = 22,
      to = 22
    }
  }
}
