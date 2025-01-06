provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-vpc"
  }
}

# Subnets
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-a"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "terraform-igw"
  }
}

# Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "terraform-route-table"
  }
}

# Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id
  name   = "terraform-sg"

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

  tags = {
    Name = "terraform-sg"
  }
}

# EC2 Instances
resource "aws_instance" "web_server_1" {
  ami                    = "ami-0fd05997b4dff7aac"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "web_server_2" {
  ami                    = "ami-0fd05997b4dff7aac"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "app_server_1" {
  ami                    = "ami-0fd05997b4dff7aac"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "app_server_2" {
  ami                    = "ami-0fd05997b4dff7aac"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "app-server-2"
  }
}

# ELB
resource "aws_elb" "bar" {
  name               = "terraform-elb"
  availability_zones = ["ap-south-1a"]
  security_groups    = [aws_security_group.sg.id]
  instances = [
    aws_instance.web_server_1.id,
    aws_instance.web_server_2.id,
    aws_instance.app_server_1.id,
    aws_instance.app_server_2.id
  ]
  tags = {
    Name = "terraform-elb"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "mohitdemoprojectofterraform-integration-1271"
  tags = {
    Name = "terraform-s3-bucket"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}
