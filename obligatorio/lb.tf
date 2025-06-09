# Crea un target group vacío

resource "aws_lb_target_group" "ob-tg" {
  name        = "ob-tg"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-ob.id
}

# Crea un ALB

resource "aws_lb" "ob-lb" {
  name               = "ob-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ob-lb-sg.id]
  subnets            = [aws_subnet.ob-private-subnet.id, aws_subnet.ob-private-subnet-2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# Crea un Listener para el ALB

resource "aws_lb_listener" "ob-listener" {
  load_balancer_arn = aws_lb.ob-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ob-tg.arn
  }
}

# Crea una regla para el listener

resource "aws_lb_listener_rule" "ob-listener-rule" {
  listener_arn = aws_lb_listener.ob-listner.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ob-tg.arn

  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}

#Llama a Launch configuration (angel

#Crea el AGS 1

resource "aws_autoscaling_group" "ob-asg" {
  launch_configuration = aws_launch_configuration.ob-asg-launch-config.id
  min_size             = 1
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.ob-private-subnet.id, aws_subnet.ob-private-subnet-2.id]

  target_group_arns = [aws_lb_target_group.ob-tg.arn]

  tags = [
    {
      key                 = "Name"
      value               = "ob-asg"
      propagate_at_launch = true
    }
  ]
}

# Crea un Target Group para el ALB2

resource "aws_lb_target_group" "alb2-tg" {
  name        = "alb2-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc-ob.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# Crea un ALB2 para recibir las consultas del ASG1

resource "aws_lb" "alb2" {
  name               = "ob-alb2"
  internal           = true # ALB interno para comunicación privada
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb2-sg.id] # SG que restringe acceso solo a ASG1
  subnets            = [aws_subnet.ob-private-subnet.id, aws_subnet.ob-private-subnet-2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# Crea un Listener para el ALB2

resource "aws_lb_listener" "alb2-listener" {
  load_balancer_arn = aws_lb.alb2.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb2-tg.arn
  }
}

resource "aws_lb" "alb2" {
  name               = "ob-alb2"
  internal           = true # ALB interno para comunicación privada
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb2-sg.id] # SG que restringe acceso solo a ASG1
  subnets            = [aws_subnet.ob-private-subnet.id, aws_subnet.ob-private-subnet-2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}


# Crea el ASG 2

resource "aws_autoscaling_group" "ob-asg2" {
  launch_configuration = aws_launch_configuration.ob-asg2-launch-config.id
  min_size             = 1
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.ob-private-subnet.id, aws_subnet.ob-private-subnet-2.id]

  target_group_arns = [aws_lb_target_group.ob-tg.arn]

  tags = [
    {
      key                 = "Name"
      value               = "ob-asg2"
      propagate_at_launch = true
    }
  ]
}