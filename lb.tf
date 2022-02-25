resource "aws_s3_bucket" "app_logs_test" {
  bucket = "app-elb-logs-test-env"
  acl    = "private"

  tags = {
    Name        = "app Logs"
  }
}

# Load balancer
resource "aws_lb" "test" {
  name            = "app-lb"
  subnets         = ["subnet-something", "subnet-something"]
  security_groups = [aws_security_group.elb.id]

   access_logs {
     bucket = aws_s3_bucket.app_logs_test.bucket
     enabled = true
  }
}

resource "aws_lb_target_group" "app" {
  name        = "app"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.app_vpc.vpc_id
  target_type = "ip"
}

# Redirect traffic from http to https
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.id
  port              = "80"
  protocol          = "HTTP"

  // default_action {
  //   target_group_arn = aws_lb_target_group.app.id
  //   type             = "forward"
  // }
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app-test.private_ip
  port             = 8080
}

data "aws_acm_certificate" "test_cert" {
  domain   = "*.my.domain.com"
  statuses = ["ISSUED"]
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.test.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.test_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}
  
  
# route 53

data "aws_route53_zone" "web" {
  name = "my.domain.com."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.web.zone_id
  name    = var.record_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.cname_record]
}
