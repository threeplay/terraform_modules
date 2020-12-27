/* CORE MODULE
 Set up the all the basic components the infrastructure sitting on
*/

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${title(var.environment)} VPC"
    Creator = "terraform"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_dhcp_options" "dhcp" {
  domain_name = "threeplayworks.com"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dhcp" {
  dhcp_options_id = aws_vpc_dhcp_options.dhcp.id
  vpc_id = aws_vpc.main.id
}
