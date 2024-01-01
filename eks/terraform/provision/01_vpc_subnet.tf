/*
  - Diagram: https://drive.google.com/file/d/11T-fm8HkKK4me6VSxykf2D6T0RKLQzuH/view?usp=sharing
  Step 1: Create a VPC
  Step 2: Create an Internet Gateway
  Step 3: Create 6 Subnets (3 public & 3 private)
  Step 4: Create an elastic-ip & nat gateway
  Step 5: Create 2 Route Tables (public & private)
  Step 6: Associate Subnets with Route Tables
*/

# Step 1: Create a VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Environment = var.environment
    Name        = "empa-vpc"
  }
}

# Step 2: Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Environment = var.environment
    Name        = "empa-igw"
  }
}

# Step 3: Create 6 Subnets (3 public & 3 private)
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true # Auto-assign IPv4: Enable

  tags = {
    Environment                                 = var.environment
    Name                                        = "empa-public-subnet-${element(var.azs, count.index)}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true # Auto-assign IPv4: Enable

  tags = {
    Environment                                 = var.environment
    Name                                        = "empa-eks-subnet-${element(var.azs, count.index)}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }
}

# Step 4: Create elastic-ip & nat gateway
resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    Environment = var.environment
    Name        = "empa-elastic-ip"
  }
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[0].id # empa-public-subnet-ap-southeast-1a

  tags = {
    Environment = var.environment
    Name        = "empa-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Step 5: Create 2 Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Environment = var.environment
    Name        = "empa-public-rtb"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Environment = var.environment
    Name        = "empa-private-rtb"
  }
}

# Step 6: Associate Subnets with Route Tables
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
