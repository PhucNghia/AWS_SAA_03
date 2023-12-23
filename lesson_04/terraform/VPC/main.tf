/*
  Step 1: Create a VPC
  Step 2: Create an Internet Gateway
  Step 3: Create Subnets
  Step 4: Create Route Tables
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

# Step 3: Create Subnets
resource "aws_subnet" "subnets" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.subnet_cidrs, count.index)
  availability_zone       = element(var.azs, 0)
  map_public_ip_on_launch = true # Auto-assign IPv4: Enable

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# Step 4: Create Route Tables
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Step 5: Associate Subnets with Route Tables
resource "aws_route_table_association" "subnet_asso" {
  count          = length(var.subnet_cidrs)
  subnet_id      = element(aws_subnet.subnets[*].id, count.index)
  route_table_id = aws_route_table.route_table.id
}
