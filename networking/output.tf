output "vpc" {
  value = aws_vpc.main
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "nat_gateways" {
  value = aws_nat_gateway.default
}

output "zones" {
  value = slice(data.aws_availability_zones.available.names, 0, length(aws_subnet.private_subnets) - 1)
}
