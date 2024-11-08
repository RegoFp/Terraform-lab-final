terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

########
# IAM
#######

# Create an IAM Role
resource "aws_iam_role" "ec2_ssm" {
  name = "EC2InstanceSSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}



resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "dev-resources-s3-policy" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"
  role = aws_iam_role.ec2_ssm.name
}



#########
# VPC
#########

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_support   = true # Enable DNS resolution
  enable_dns_hostnames = true # Enable DNS hostnames

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
    Name  = "nat_to_public 1"
    ENV   = var.env
    OWNER = "IT"
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
    Name  = "nat_to_public_2"
    ENV   = var.env
    OWNER = "IT"
  }

  depends_on = [aws_internet_gateway.main_igw]
}


##### ##
#  Routing tables
#######

# Publicas con IGW

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

# Privados con nat

## Una
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

# La otra

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


#######
# Route 53
########
resource "aws_route53_zone" "private" {
  name = "backend.com"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name  = "R53_Jardinalia"
    ENV   = var.env
    OWNER = "IT"
  }
}

resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.backend.com"
  type    = "CNAME"
  records = [split(":", module.rds.db_instance_endpoint)[0]]
  ttl     = 60
}



resource "aws_route53_record" "redis" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "redis.backend.com"
  type    = "CNAME"
  records = [module.elasticache.cluster_cache_nodes[0].address]
  ttl     = 60
}

resource "aws_route53_record" "memcached" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "memcached.backend.com"
  type    = "CNAME"
  records = [module.memcached.cluster_cache_nodes[0].address]
  ttl     = 60
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "alb.backend.com"
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true
  }
}

#########
#  RDS
#########

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0" # Make sure to check for the latest version

  identifier        = "rds-jardinalia"
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  family = "postgres14"

  manage_master_user_password = false

  snapshot_identifier = "arn:aws:rds:us-east-1:842675980926:snapshot:ready-jardinalia-2"

  skip_final_snapshot = true

  # db_name                 = "jardinalia" # Initial database name
  # username                = "jardinero"  # Master username
  # password                = "jardinero" # Master password
  publicly_accessible     = false
  backup_retention_period = 1

  # Subnet group configuration
  create_db_subnet_group = true
  subnet_ids             = [aws_subnet.main_subnet_private_1.id, aws_subnet.main_subnet_private_2.id] # Replace with your actual subnet IDs

  # Security group configuration
  vpc_security_group_ids = [aws_security_group.RDS_allow_instance_traffic.id] # Referencing the security group created below

  # Additional configuration for cost savings
  multi_az                     = false
  auto_minor_version_upgrade   = false
  deletion_protection          = false
  performance_insights_enabled = false

  # Tags
  tags = {
    Name  = "DB_Jardinalia"
    ENV   = var.env
    OWNER = "IT"
  }
}

#########
# AWS Secrets Manager
#########

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "db_credenciales"
  description = "Credenciales para jardinero"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "jardinero"
    password = "jardinero"
  })
}



# Import existing certificate into ACM
resource "aws_acm_certificate" "certs" {
  private_key       = file("Certs/clave.pem")
  certificate_body  = file("Certs/certificado.pem")

  tags = {
    Name  = "backend-cert"
    ENV   = var.env
    OWNER = "IT"
  }
}

#########
#  ALB
#########

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "albjardinalia"
  vpc_id  = aws_vpc.main.id
  subnets = [aws_subnet.main_subnet_public_1.id, aws_subnet.main_subnet_public_2.id]

  security_groups = [aws_security_group.ALB_allow_http_https.id]

  enable_deletion_protection = false

  create_security_group = false
  
  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ex_asg"
      }
    }

    ex_https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.certs.arn

      forward = {
        target_group_key = "ex_asg"
      }
    }

  }

  target_groups = {
    ex_asg = {
      name_prefix = "h1"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"

      create_attachment = false

      health_check = {
        path                = "/health/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
        protocol            = "HTTP"

        matcher = "200"

      }

    }
  }
}

#########
#  Redis
#########

module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id               = "redisjardinalia"
  create_cluster           = true
  create_replication_group = false

  engine_version = "7.1"
  node_type      = "cache.t4g.small"
  # az_mode         = "cross-az"

  apply_immediately = true

  # Security group
  vpc_id             = aws_vpc.main.id
  security_group_ids = [aws_security_group.Redis_allow_instance_traffic.id]

  # Subnet Group
  subnet_ids = [aws_subnet.main_subnet_private_1.id, aws_subnet.main_subnet_private_2.id]

  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = {
    Name  = "Redis_Jardinalia"
    ENV   = var.env
    OWNER = "IT"

  }
}


#####
#   ASG
####

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "asg-jardinalia"

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.main_subnet_private_1.id, aws_subnet.main_subnet_private_2.id]

  security_groups = [
    aws_security_group.web_server_http_https.id,
    aws_security_group.instance_sg_1.id,
    aws_security_group.ec2_rds_1.id,
    aws_security_group.ec2_redis_1.id,
    aws_security_group.instance_memcached.id
  ]

  image_id          = "ami-0ed928892998f8eea"
  instance_type     = "t2.micro"
  ebs_optimized     = true
  enable_monitoring = true

  iam_instance_profile_name = aws_iam_instance_profile.ssm_profile.name

  # Traffic source attachment
  traffic_source_attachments = {
    ex-alb = {
      traffic_source_identifier = module.alb.target_groups["ex_asg"].arn
      traffic_source_type       = "elbv2" # default
    }
  }


  tags = {
    Name  = "ASG_Jardinalia"
    OWNER = "IT"

  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum install -y amazon-efs-utils
              sudo mkdir /efs
              sudo mount -t efs -o tls ${aws_efs_file_system.jardinalia_efs.id}:/ /efs
              EOF
  )

}

resource "aws_s3_bucket" "bucket" {
  bucket = "jardinalia-bucket-66343156"
  force_destroy = true
}




resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_ssm.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

#########
# EFS
#########

# Create EFS File System
resource "aws_efs_file_system" "jardinalia_efs" {
  creation_token = "jardinalia-efs"
  encrypted      = true


  tags = {
    Name  = "Jardinalia_EFS"
    ENV   = var.env
    OWNER = "IT"
  }
}

# Create mount targets in private subnets
resource "aws_efs_mount_target" "private_1" {
  file_system_id  = aws_efs_file_system.jardinalia_efs.id
  subnet_id       = aws_subnet.main_subnet_private_1.id
  security_groups = [aws_security_group.EFS_allow_instance_traffic.id]
}

resource "aws_efs_mount_target" "private_2" {
  file_system_id  = aws_efs_file_system.jardinalia_efs.id
  subnet_id       = aws_subnet.main_subnet_private_2.id
  security_groups = [aws_security_group.EFS_allow_instance_traffic.id]
}

#########
# ElastiCache Memcached
#########

module "memcached" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id           = "memcached-jardinalia"
  create_cluster       = true
  create_replication_group = false

  engine               = "memcached"
  node_type            = "cache.t4g.micro" # Choose a cost-effective instance type
  num_cache_nodes      = 1                   # Number of nodes in the cluster
  parameter_group_name = "default.memcached1.6" # Default parameter group for Memcached

  # Security group
  vpc_id             = aws_vpc.main.id
  subnet_ids = [aws_subnet.main_subnet_private_1.id, aws_subnet.main_subnet_private_2.id]
  security_group_ids = [aws_security_group.Memcached_allow_instance_traffic.id]
  

  tags = {
    Name  = "Memcached_Jardinalia"
    ENV   = var.env
    OWNER = "IT"
  }
}

#########
#  NLB
#########
resource "aws_lb" "nlb-jardinalia" {
  name               = "nlb-jardinalia"
  internal           = false
  load_balancer_type = "network"

  security_groups    = [aws_security_group.nlb-sg.id]

  subnet_mapping {
    subnet_id = aws_subnet.main_subnet_public_1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.main_subnet_public_2.id
  }

  tags = {
    Name          = "nlb-jardinalia"
    ENV          = var.env
    OWNER         = "IT"
  }
}

# Target group para el NLB
resource "aws_lb_target_group" "nlb-tg" {
  name        = "nlb-tg"
  
  vpc_id      = aws_vpc.main.id
  protocol    = "TCP"
  port        = 80
  target_type = "alb"
  health_check {
    protocol = "HTTP"
    port     = 80
  }
  tags = {
    Name          = "nlb-tg"
    ENV          = var.env
    OWNER         = "IT"
  }
}

# Asociar el target group del NLB
resource "aws_lb_target_group_attachment" "nlb-attach" {

  target_group_arn = aws_lb_target_group.nlb-tg.arn
  target_id        = module.alb.arn

  depends_on = [module.alb ]

}

resource "aws_lb_listener" "nlb-listener" {
  load_balancer_arn = aws_lb.nlb-jardinalia.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-tg.arn
  }
}
