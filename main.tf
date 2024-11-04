terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
    

# VPC --------------------------------
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  
  enable_dns_support   = true  # Enable DNS resolution
  enable_dns_hostnames = true  # Enable DNS hostnames
  
  tags = {
    Name  = "VPC Terraform"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "IGW_1"
    ENV   = var.env
    OWNER = "IT"
  }

}

##  Subnets

resource "aws_subnet" "main_subnet_public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "main_subnet_public_1"
     ENV   = var.env
    
  }
}

resource "aws_subnet" "main_subnet_public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    "Name" = "main_subnet_public_2"
    ENV   = var.env
  }
}

resource "aws_subnet" "main_subnet_private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.128.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "main_subnet_private_1"
    ENV   = var.env
  }
}

resource "aws_subnet" "main_subnet_private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.192.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
  

  tags = {
    "Name" = "main_subnet_private_2"
    ENV   = var.env
  }
}

# Networking -----

    
# NAT
# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip_public_1" {
    domain = "vpc"
}

resource "aws_nat_gateway" "NAT_public_1" {
  allocation_id = aws_eip.nat_eip_public_1.id
  subnet_id     = aws_subnet.main_subnet_public_1.id

  tags = {
    Name = "nat public 1"
  }

  depends_on = [aws_internet_gateway.main_igw]
}


# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip_public_2" {
    domain = "vpc"
}

resource "aws_nat_gateway" "NAT_public_2" {
  allocation_id = aws_eip.nat_eip_public_2.id
  subnet_id     = aws_subnet.main_subnet_public_2.id

  tags = {
    Name = "nat public 2"
  }

  depends_on = [aws_internet_gateway.main_igw]
}


# Routing tables

## Publicas con IGW

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "route table public"
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

# Privados con nat

## Una
resource "aws_route_table" "route_table_private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_public_1.id
  }

  tags = {
    Name = "route table private 1"
  }
}

resource "aws_route_table_association" "private_route_1" {
  subnet_id      = aws_subnet.main_subnet_private_1.id
  route_table_id = aws_route_table.route_table_private_1.id
}

# La otra

resource "aws_route_table" "route_table_private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_public_2.id
  }

  tags = {
    Name = "route table private 2"
  }
}

resource "aws_route_table_association" "private_route_2" {
  subnet_id      = aws_subnet.main_subnet_private_2.id
  route_table_id = aws_route_table.route_table_private_2.id
}

## Instaces --------
resource "aws_instance" "instance_1" {
  ami           = "ami-00b9c94ad8bfbd110"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet_public_1.id
  security_groups = [aws_security_group.allow_all_testing.id]
  iam_instance_profile = "EC2"
  associate_public_ip_address = true

  depends_on = [ module.rds ]

  tags = {
    Name = "TEST"
    ENV = "to-delete"
    Owner = "IT"
  }

}

# Security groups ------
# Security groups ----------
resource "aws_security_group" "allow_all_testing" {
  name        = "allow_all_traffic"
  description = "Security group that allows all inbound and outbound traffic"
  vpc_id      = aws_vpc.main.id  # Replace with your VPC ID

  # Inbound rule: Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"   # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow All Traffic"
  }
}

## Route 53
resource "aws_route53_zone" "private" {
  name = "backend.com"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name     = "db.backend.com"  # The local DNS name for your database
  type     = "CNAME"  # CNAME is the correct type for pointing to RDS
  records   = [split(":", module.rds.db_instance_endpoint)[0]]  # Use the RDS instance endpoint
  ttl      = 60
}


module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"  # Make sure to check for the latest version

  identifier         = "jardibase"
  engine             = "postgres"
  engine_version     = "14"
  instance_class     = "db.t4g.micro"
  allocated_storage  = 20
  storage_type       = "gp2"

  family = "postgres14"

  manage_master_user_password = false

  db_name               = "jardinalia"     # Initial database name
  username           = "jardinero"             # Master username
  password           = "adminadmin"    # Master password
  publicly_accessible = true
  backup_retention_period = 1

  # Subnet group configuration
  create_db_subnet_group = true
  subnet_ids = [aws_subnet.main_subnet_private_1.id, aws_subnet.main_subnet_private_2.id] # Replace with your actual subnet IDs

  # Security group configuration
  vpc_security_group_ids = [aws_security_group.allow_all_testing.id]  # Referencing the security group created below

  # Additional configuration for cost savings
  multi_az                  = false
  auto_minor_version_upgrade = false
  deletion_protection       = false
  performance_insights_enabled = false

  # Tags
  tags = {
    Name = "database"
  }
}