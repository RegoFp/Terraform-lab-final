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
    OWNER = var.owner

  }

  # Instala amazon linux utils y monta el EFS
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum install -y amazon-efs-utils
              sudo mkdir /efs
              sudo mount -t efs -o tls ${aws_efs_file_system.jardinalia_efs.id}:/ /efs
              EOF
  )

}