provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "vpc-01202fc5dc6356643"
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = "vpc-01202fc5dc6356643"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = "vpc-01202fc5dc6356643"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-039a72ac5f27670da"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = "subnet-00ec9116e78b9a260"
  route_table_id = "rtb-00e92f21815ac0537"
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  vpc_id = "vpc-01202fc5dc6356643"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

# EC2 with Docker Auto Install
resource "aws_instance" "app_server" {
  ami                    = "ami-0f3caa1cf4417e51b" # Replace with Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  subnet_id              = "subnet-00ec9116e78b9a260"
  vpc_security_group_ids = [sg-00cf5e1f75b5f89ce]
  key_name               = "jenkins-docker"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              systemctl start docker
              usermod -aG docker ec2-user
              EOF

  tags = {
    Name = "jenkins-docker-server"
  }
}
