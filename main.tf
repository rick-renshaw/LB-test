# test to set up an LB and instance

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "http" {
  vpc_id      = var.vpc_id
  name        = "lb-test-allow-http"
  description = "allow port 80"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = local.mps_cidrs
    description = "Allow access to port 80 from our networks"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow everything out"
  }
}

resource "aws_security_group" "ssh" {
  vpc_id      = var.vpc_id
  name        = "lb-test-allow-ssh"
  description = "allow port 22"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = local.mps_cidrs
    description = "Allow access to port 22 from our networks"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow everything out"
  }
}

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.http.id, aws_security_group.ssh.id]
  key_name               = "prod-aws-nexus-11-04-2021"
  user_data_base64       = filebase64("${path.module}/nginx.sh")
  monitoring             = true
  ebs_optimized          = true
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = true
  }
  tags = {
    Name = "LB-test"
  }
}

resource "aws_lb" "lbtest" {
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "test-load-balancer"
  preserve_host_header       = false
  security_groups            = [aws_security_group.http.id]
  subnets                    = [var.subnet_id, var.subnet_b_id]
  enable_deletion_protection = true
  drop_invalid_header_fields = true
  access_logs {
    bucket  = aws_s3_bucket.fib.bucket
    prefix  = "test-lb"
    enabled = true
  }
}

resource "aws_lb_target_group" "port_80" {
  name     = "LB-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled           = true
    healthy_threshold = 3
    interval          = 30
    matcher           = "200-299"
    path              = "/"
  }
}

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = aws_lb.lbtest.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.port_80.arn
  }
}

resource "aws_lb_target_group_attachment" "target" {
  target_group_arn = aws_lb_target_group.port_80.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}

resource "aws_s3_bucket" "fib" {
  bucket        = "mpspark-test-bucket"
  force_destroy = true
  tags = {
    Name = "foo-bucket"
  }
  versioning {
    enabled = true
  }
  
}