# ALB


resource "aws_security_group" "ALB_allow_http_https" {
  name        = "ALB_allow_http_https"
  description = "Security group to allow all HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.main.id  // Replace with your VPC ID

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "ALB_allow_http_https"
    ENV = var.env
    OWNER = "IT"

  }
}

# RDS
resource "aws_security_group" "RDS_allow_instance_traffic" {
  name        = "rds_allow_instance_traffic"
  description = "Security group to allow traffic from instances to RDS"
  vpc_id      = aws_vpc.main.id  // Replace with your VPC ID

  ingress {
    description     = "Allow traffic from instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_rds_1.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name  = "rds_allow_instance_traffic"
    ENV   = var.env
    OWNER = "IT"
  }
}

# ElastiCache
resource "aws_security_group" "Redis_allow_instance_traffic" {
  name        = "Redis_allow_instance_traffic"
  description = "Security group to allow traffic from instances to ElastiCache"
  vpc_id      = aws_vpc.main.id  // Replace with your VPC ID

  ingress {
    description     = "Allow traffic from instances"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_redis_1.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name  = "Redis_allow_instance_traffic"
    ENV   = var.env
    OWNER = "IT"
  }
}

# EFS

resource "aws_security_group" "EFS_allow_instance_traffic" {
  name        = "EFS_allow_instance_traffic"
  description = "Security group to allow traffic from instances to EFS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow NFS traffic from instances"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.instance_sg_1.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name  = "EFS_allow_instance_traffic"
    ENV   = var.env
    OWNER = "IT"
  }
}

# Instance 
# Security group for web servers allowing HTTP/HTTPS from ALB
resource "aws_security_group" "web_server_http_https" {
  name        = "web-server-http-https"
  description = "Allow HTTP/HTTPS traffic from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_allow_http_https.id]
  }

  ingress {
    description     = "Allow HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_allow_http_https.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name  = "web-server-http-https"
    ENV   = var.env
    OWNER = "IT"
  }
}

# Security group for NFS outbound traffic to EFS
resource "aws_security_group" "instance_sg_1" {
  name        = "instance-sg-1"
  description = "Allow outbound NFS traffic to EFS"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "instance-sg-1"
    ENV   = var.env
    OWNER = "IT"
  }
}

# Security group for RDS outbound traffic
resource "aws_security_group" "ec2_rds_1" {
  name        = "ec2-rds-1"
  description = "Allow outbound PostgreSQL traffic to RDS"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "ec2-rds-1"
    ENV   = var.env
    OWNER = "IT"
  }
}

# Security group for Redis outbound traffic
resource "aws_security_group" "ec2_redis_1" {
  name        = "ec2-redis-1"
  description = "Allow outbound Redis traffic to ElastiCache"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "ec2-redis-1"
    ENV   = var.env
    OWNER = "IT"
  }
}