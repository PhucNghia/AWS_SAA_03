/*
    - buy a domain (danlv3.pro) with namecheap.com (~3$)
    - add domain to hosted zones with aws
        + Step 1. create a hosted zones with domain = danlv3.pro
        + Step 2. create records: record type = A, value = id of ec2 instanses
        + Step 3. add nameserver: add 4 values of records (type = NS) to nameserver of namecheap.com
*/

# Step 1. create a hosted zones
resource "aws_route53_zone" "rz" {
  name    = "danlv3.pro"
  comment = "create route53 zone"
  tags = {
    Environment = "dev"
  }
}

# Step 2. create records: record type = A, value = id of ec2 instanses
resource "aws_route53_record" "simple_record" {
  zone_id = aws_route53_zone.rz.zone_id
  name    = "www.danlv3.pro"
  type    = "A"
  ttl     = "300"
  records = var.ec2_instance_public_ips
}

# Step 3. add nameserver: add 4 values of records (type = NS) to nameserver of namecheap.com
resource "local_file" "name_server" {
  content  = aws_route53_zone.rz.primary_name_server
  filename = "${path.module}/name_server.txt"
}

