resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  cidr_block = var.private_subnets[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Private Subnet: ${title(var.environment)}"
    Visibility = "private"
    Creator = "terraform"
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.default, count.index).id
  }

  tags = {
    Name = "Private routing"
    Creator = "terraform"
    Visibility = "Private"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  route_table_id = aws_route_table.private[count.index].id
  subnet_id = aws_subnet.private_subnets[count.index].id
}

resource "aws_security_group" "private_access" {
  name = "Private NAT Access"
  description = "Internet Access for private nodes"
  vpc_id = aws_vpc.main.id
  tags = {
    Visibility = "private"
    Creator = "terraform"
    Environment = var.environment
  }

  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
  }

  // Outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
