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
    OWNER = var.owner
  }
}