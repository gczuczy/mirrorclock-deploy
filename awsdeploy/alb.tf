
resource "aws_alb" "application_load_balancer" {
  name = "${var.appname_short}-alb"
  internal = false
  load_balancer_type = "application"
  subnets = aws_subnet.mc-public.*.id
  security_groups = [
    aws_security_group.load_balancer_sg.id
  ]

   tags = {
    Name = "${var.appname_short}-alb"
    Environment = var.appenv
  }
}

resource "aws_security_group" "load_balancer_sg" {
  vpc_id = aws_vpc.service-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

   tags = {
    Name = "${var.appname_short}-sg"
    Environment = var.appenv
  }
}

resource "aws_lb_target_group" "target_group" {
  name = "${var.appname_short}-tg"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.service-vpc.id

  health_check {
    healthy_threshold = "3"
    interval = "300"
    protocol = "HTTP"
    timeout = "3"
    path = "/api/v1/healthcheck"
    unhealthy_threshold = "2"
  }

  tags = {
    Name = "${var.appname_short}-tg"
    Environment = var.appenv
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}
