resource "aws_lb" "alb" {
  name               = var.namespace
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg]
  subnets            = var.vpc.public_subnets
  enable_deletion_protection = false
  tags = {
    Name             = "public access ALB"
  }
}

resource "aws_lb_target_group" "default" {
  name     = "default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc.vpc_id

  stickiness {
      type = "lb_cookie"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

resource "aws_lb_listener" "http_to_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = var.instanceid
  port             = 8080
}
