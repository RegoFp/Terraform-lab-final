resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true 

  tags = {
    Name  = "VPC Terraform"
    ENV   = var.env
    OWNER = "IT"
  }
}

# IGW

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "IGW_1"
    ENV   = var.env
    OWNER = "IT"
  }

}

#  Subnets

resource "aws_subnet" "main_subnet_public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name  = "main_subnet_public_1"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_subnet" "main_subnet_public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name  = "main_subnet_public_2"
    ENV   = var.env
    Owner = "IT"
  }
}

resource "aws_subnet" "main_subnet_private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.128.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = {
    Name  = "main_subnet_private_1"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_subnet" "main_subnet_private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.192.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"


  tags = {
    Name  = "main_subnet_private_2"
    ENV   = var.env
    OWNER = "IT"
  }
}

# Create an Elastic IP for the NAT Gateway of the 1st private subnet
resource "aws_eip" "nat_eip_public_1" {
  domain = "vpc"
}

# NAT for the 1st private subnet
resource "aws_nat_gateway" "NAT_public_1" {
  allocation_id = aws_eip.nat_eip_public_1.id
  subnet_id     = aws_subnet.main_subnet_public_1.id

  tags = {
    Name  = "nat_to_public 1"
    ENV   = var.env
    OWNER = "IT"
  }

  depends_on = [aws_internet_gateway.main_igw]
}


# Create an Elastic IP for the NAT Gateway of the 2nd private subnet
resource "aws_eip" "nat_eip_public_2" {
  domain = "vpc"
}

# NAT for the 2st private subnet
resource "aws_nat_gateway" "NAT_public_2" {
  allocation_id = aws_eip.nat_eip_public_2.id
  subnet_id     = aws_subnet.main_subnet_public_2.id

  tags = {
    Name  = "nat_to_public_2"
    ENV   = var.env
    OWNER = "IT"
  }

  depends_on = [aws_internet_gateway.main_igw]
}



# Routing tables

# Public towards IGW
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name  = "route_table_public"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_route_table_association" "public_route_1" {
  subnet_id      = aws_subnet.main_subnet_public_1.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "public_route_2" {
  subnet_id      = aws_subnet.main_subnet_public_2.id
  route_table_id = aws_route_table.route_table_public.id
}

# Private towards NAT

resource "aws_route_table" "route_table_private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_public_1.id
  }

  tags = {
    Name  = "route_table_private_1"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_route_table_association" "private_route_1" {
  subnet_id      = aws_subnet.main_subnet_private_1.id
  route_table_id = aws_route_table.route_table_private_1.id
}


resource "aws_route_table" "route_table_private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_public_2.id
  }

  tags = {
    Name  = "route_table_to_private 2"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_route_table_association" "private_route_2" {
  subnet_id      = aws_subnet.main_subnet_private_2.id
  route_table_id = aws_route_table.route_table_private_2.id
}