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
