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
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB_allow_http_https"
    ENV = var.env
    OWNER = "IT"

  }
}