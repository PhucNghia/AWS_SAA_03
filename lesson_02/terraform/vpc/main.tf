/*
  - Diagram: https://drive.google.com/file/d/11T-fm8HkKK4me6VSxykf2D6T0RKLQzuH/view?usp=sharing
  Step 1: Create a VPC
  Step 2: Create an Internet Gateway
  Step 3: Create 2 Subnets (public & private)
  Step 4: Create 2 Route Tables (public & private)
  Step 5: Associate Subnets with Route Tables
*/

# Step 1: Create a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "Project VPC"
  }
}

# Step 2: Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "Project VPC IG"
  }
}

# Step 3: Create 2 Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, 0)
  map_public_ip_on_launch = true # Auto-assign IPv4: Enable

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, 1)
  map_public_ip_on_launch = true # Auto-assign IPv4: Enable

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# Step 4: Create 2 Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Step 5: Associate Subnets with Route Tables
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
