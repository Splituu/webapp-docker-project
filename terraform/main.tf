resource "aws_instance" "webapp" {
  instance_type          = "t3.micro"
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]
  key_name               = "webapp-demo"
  tags = {
    Name = "webapp"
  }

  user_data = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    echo "Updating apt-get"
    apt-get update
    echo "Installing docker, docker compose and git"
    apt-get install -y docker.io docker-compose-v2 git
    systemctl enable --now docker
    echo "Cloning repository"
    git clone https://github.com/Splituu/webapp-docker-project.git /opt/webapp
    cd /opt/webapp
    echo "Starting application"
    docker compose up -d --build
  EOF
}

resource "aws_security_group" "webapp_sg" {
  name        = "${var.project}-webapp-sg"
  description = "Security group for webapp"
  vpc_id      = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc_security_group_ingress_rule" "app_8080" {
  security_group_id = aws_security_group.webapp_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "ssh_access" {
  security_group_id = aws_security_group.webapp_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.webapp_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

