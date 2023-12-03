output "ec2_instance_ids" {
  value = aws_instance.public_ec2[*].id
}

output "ec2_instance_names" {
  value = aws_instance.public_ec2[*].tags["Name"]
}

output "ec2_instance_public_ips" {
  value = aws_instance.public_ec2[*].public_ip
}
