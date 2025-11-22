data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "alb" {
  name        = "${var.common_tags.Project}-${var.environment}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.common_tags.Project}-${var.environment}-alb-sg" }
  )
}

resource "aws_security_group" "ec2" {
  name        = "${var.common_tags.Project}-${var.environment}-ec2-sg"
  description = "EC2 security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.common_tags.Project}-${var.environment}-ec2-sg" }
  )
}

resource "aws_lb" "this" {
  name               = "${var.common_tags.Project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = merge(
    var.common_tags,
    { Name = "${var.common_tags.Project}-${var.environment}-alb" }
  )
}

resource "aws_lb_target_group" "this" {
  name     = "${var.common_tags.Project}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.common_tags.Project}-${var.environment}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              echo "Hello from ${var.environment} environment" > /usr/share/nginx/html/index.html
              systemctl enable nginx
              systemctl start nginx
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      { Name = "${var.common_tags.Project}-${var.environment}-ec2" }
    )
  }

  tags = var.common_tags
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.common_tags.Project}-${var.environment}-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.this.arn]

  tag {
    key                 = "Name"
    value               = "${var.common_tags.Project}-${var.environment}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
