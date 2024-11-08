#########
#  ALB
#########

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "albjardinalia"
  vpc_id  = aws_vpc.main.id
  subnets = [aws_subnet.main_subnet_private_1.id, aws_subnet.main_subnet_private_2.id]
  internal = true
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