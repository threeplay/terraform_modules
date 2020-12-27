resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  cidr_block = var.public_subnets[count.index]
  vpc_id = aws_vpc.main.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "Public Subnet: ${title(var.environment)}"
    Visibility = "public"
    Creator = "terraform"
  }
}

// NAT Gateway for each public subnet
resource "aws_nat_gateway" "default" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public_subnets[count.index].id
}

resource "aws_eip" "nat_eip" {
  count = length(var.public_subnets)
  vpc = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "Internet Gateway: ${title(var.environment)}"
    Environment = var.environment
    Creator = "terraform"
    Visibility = "public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public_subnets[count.index].id
}

resource "aws_security_group" "public_access" {
  name = "Public Security Group"
  description = "Internet Access for public nodes"
  tags = {
    Creator = "terraform"
    Environment = var.environment
    Visibility = "public"
  }
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.public_ingress

    content {
      protocol = ingress.value.protocol
      from_port = ingress.value.from
      to_port = ingress.value.to
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.key
    }
  }

  ingress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    self = true
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

