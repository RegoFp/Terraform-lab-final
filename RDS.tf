
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