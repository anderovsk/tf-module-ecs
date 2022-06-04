
resource "aws_lb_target_group" "tg" {
  name        = "${var.name}-${var.env}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

    health_check {
    path                = "/health"
    port                = "traffic-port" 
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb" "elb" {
  name               = "${var.name}-${var.env}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.subnet_public_ids
  enable_deletion_protection = false
}

resource "aws_lb_listener" "elb-listener-http" {
  load_balancer_arn = aws_lb.elb.arn
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


 resource "aws_lb_listener" "elb-listener-https" {
   load_balancer_arn = aws_lb.elb.arn
   port              = "443"
   protocol          = "HTTPS"
   ssl_policy        = "ELBSecurityPolicy-2016-08"
   certificate_arn   = var.certificate_arn

   default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.tg.arn
   }
 }
