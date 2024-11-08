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
