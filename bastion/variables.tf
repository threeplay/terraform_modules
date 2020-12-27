variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "bastion_instance_size" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ssh_ingress_ips" {
  type = list(string)
  default = []
}
