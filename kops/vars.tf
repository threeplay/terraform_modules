variable "domain" {
  type = string
  description = "Cluster domain, ie: example.com"
}

variable "cluster_name" {
  type = string
  description = "Cluster name, ie: prototype (full cluster domain will be prototype.example.com)"
}

variable "dns_zone_id" {
  type = string
  description = "DNS Zone id to assign DNS name"
}

variable "k8s_version" {
  type = string
  default = "1.15.6"
  description = "k8s version to deploy (must be consistent with the image)"
}

variable "k8s_image" {
  type = string
  default = "kope.io/k8s-1.15-debian-stretch-amd64-hvm-ebs-2019-09-26"
  description = "k8s image"
}

variable "vpc_id" {
  type = string
  description = "VPC Id"
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR"
}
variable "public_subnets" {
  type = map(object({
    cidr = string
    zone = string
    subnet_id = string
  }))
  default = {}
  description = "Map of public subnets { cidr, zone, subnet_id }"
}

variable "utility_subnets" {
  type = map(object({
    cidr = string
    zone = string
    subnet_id = string
  }))
  default = {}
  description = "Map of utility subnets { cidr, zone, subnet_id }"
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    zone = string
    subnet_id = string
    egress_id = string
  }))
  default = {}
  description = "Map of private subnets { cidr, zone, subnet_id, egress }"
}

variable "nodes" {
  type = map(object({
    type = string             // Instance type of nodes
    subnets = list(string)    // Subnets nodes allowed to use
    min_count = number        // Minimum number of instances
    max_count = number        // Maximum number of instances
  }))
}

variable "masters_subnets" {
  type = list(string)
  description = "List of subnets to put masters in"
}

variable "masters_instance_size" {
  type = string
  description = "Instance size for master"
}
