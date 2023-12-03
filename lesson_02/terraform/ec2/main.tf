/*
    Step 1. Create Security Group
    Step 2. Create key pair
    Step 3. Create public & internal instances
*/

# Step 1. Create Security Group
resource "aws_security_group" "web_sg" {
  name   = "HTTP and SSH"
  vpc_id = var.custom_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Step 2. Create key pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "public_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.module}/ec2_key.pem"
}

# Step 3. Create public & internal instances
resource "aws_instance" "public_ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.public_key.key_name
  count                  = length(var.public_subnet_ids)
  subnet_id              = element(var.public_subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = <<EOF
    #!/bin/bash
    echo "Installing apache..."

    sudo apt update
    sudo apt install apache2
    sudo ufw allow 'Apache'
    sudo chmod -R 777 /var/www/html
    sudo echo "<html><body><h2>Hello world from private ip: $(hostname -I)</h2></body></html>" > /var/www/html/index.html
    sudo systemctl restart apache2
  EOF

  tags = {
    Name = "public ec2-0${count.index + 1}"
  }
}

resource "aws_instance" "internal_ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.public_key.key_name
  count                  = length(var.private_subnet_ids)
  subnet_id              = element(var.private_subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "Internal ec2-0${count.index + 1}"
  }
}
