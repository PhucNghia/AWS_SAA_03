output "custom_vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.subnets[*].id
}

output "azs" {
  value = var.azs
}
