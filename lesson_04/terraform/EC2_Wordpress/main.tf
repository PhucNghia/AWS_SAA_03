/*
    Step 1. Create Security Group
    Step 2. Create key pair
    Step 3. Create EC2 instances (install wordpress via user-data)
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

# Step 3. Create EC2 instance
resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.public_key.key_name
  count                  = length(var.subnet_ids)
  subnet_id              = element(var.subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = <<EOF
    #!/bin/bash -xe
    # https://gist.github.com/11808s8/ef00edb98867d490742755f1887695ad

    sudo -i
    # STEP 1 - Setpassword & DB Variables
    DBName='a4lwordpress'
    DBUser='a4lwordpress'
    DBPassword='4n1m4l$4L1f3'
    DBRootPassword='4n1m4l$4L1f3'

    # STEP 2 - Install system software - including Web and DB
    dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel cowsay -y
    
    # STEP 3 - Web and DB Servers Online - and set to startup
    systemctl enable httpd
    systemctl enable mariadb
    systemctl start httpd
    systemctl start mariadb
    
    # STEP 4 - Set Mariadb Root Password
    mysqladmin -u root password $DBRootPassword
    
    # STEP 5 - Install Wordpress
    wget http://wordpress.org/latest.tar.gz -P /var/www/html
    cd /var/www/html
    tar -zxvf latest.tar.gz
    cp -rvf wordpress/* .
    rm -R wordpress
    rm latest.tar.gz
    
    # STEP 6 - Configure Wordpress
    cp ./wp-config-sample.php ./wp-config.php
    sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
    sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
    sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
    
    # Step 6a - permissions 
    usermod -a -G apache ec2-user   
    chown -R ec2-user:apache /var/www
    chmod 2775 /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod 0664 {} \;
    
    # STEP 7 Create Wordpress DB
    echo "CREATE DATABASE $DBName;" >> /tmp/db.setup
    echo "CREATE USER '$DBUser'@'localhost' IDENTIFIED BY '$DBPassword';" >> /tmp/db.setup
    echo "GRANT ALL ON $DBName.* TO '$DBUser'@'localhost';" >> /tmp/db.setup
    echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
    mysql -u root --password=$DBRootPassword < /tmp/db.setup
    sudo rm /tmp/db.setup
    
    # STEP 8 COWSAY
    echo "#!/bin/sh" > /etc/update-motd.d/40-cow
    echo 'cowsay "Amazon Linux 2023 AMI - Animals4Life"' >> /etc/update-motd.d/40-cow
    chmod 755 /etc/update-motd.d/40-cow
    update-motd

  EOF

  tags = {
    Name = "public ec2-0${count.index + 1}"
  }
}
