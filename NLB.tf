#########
#  NLB
#########
resource "aws_lb" "nlb-jardinalia" {
  name               = "nlb-jardinalia"
  internal           = false
  load_balancer_type = "network"

  security_groups    = [aws_security_group.nlb_web_traffic.id]

  subnet_mapping {
    subnet_id = aws_subnet.main_subnet_public_1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.main_subnet_public_2.id
  }

  tags = {
    Name          = "nlb-jardinalia"
    ENV          = var.env
    OWNER         = var.owner
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
    OWNER         = var.owner
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
