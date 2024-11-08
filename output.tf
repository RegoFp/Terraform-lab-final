# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnets
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.main_subnet_private_1.id, aws_subnet.main_subnet_private_2.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.main_subnet_public_1.id, aws_subnet.main_subnet_public_2.id]
}

# Security Groups
output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.ALB_allow_http_https.id
}

output "instance_security_group_id" {
  description = "The ID of the EC2 instance security group"
  value       = aws_security_group.instance_sg_1.id
}

# Load Balancer
output "alb_dns_name" {
  description = "The DNS name of the application load balancer"
  value       = module.alb.dns_name
}

# Auto Scaling Group
output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_name
}

# EFS
output "efs_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.jardinalia_efs.id
}

# S3
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.bucket.arn
}
# RDS Security Group
output "rds_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.RDS_allow_instance_traffic.id
}

# Redis Security Group 
output "redis_security_group_id" {
  description = "The ID of the EC2 to Redis security group"
  value       = aws_security_group.ec2_redis_1.id
}

# EFS Security Group
output "efs_security_group_id" {
  description = "The ID of the EFS security group"
  value       = aws_security_group.EFS_allow_instance_traffic.id
}

# EC2 to RDS Security Group
output "ec2_rds_security_group_id" {
  description = "The ID of the EC2 to RDS security group"
  value       = aws_security_group.ec2_rds_1.id
}


output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# CloudFront
output "cloudfront_dns_name" {
  description = "The DNS name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.wordpress_distribution.domain_name
}

