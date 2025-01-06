provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "one" {
  ami                   = "ami-0fd05997b4dff7aac"
  instance_type         = "t2.micro"
  key_name              = "server"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone     = "ap-south-1a"
  user_data             = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "hai all this is my app created by terraform infrastructurte by prashant sir server-1" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "two" {
  ami                   = "ami-0fd05997b4dff7aac"
  instance_type         = "t2.micro"
  key_name              = "server"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone     = "ap-south-1c"
  user_data             = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "hai all this is my website created by terraform infrastructurte by prashant sir server-2" > /var/www/html/index.html
EOF
  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "three" {
  ami                   = "ami-0fd05997b4dff7aac"
  instance_type         = "t2.micro"
  key_name              = "server"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone     = "ap-south-1b"
  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "four" {
  ami                   = "ami-0fd05997b4dff7aac"
  instance_type         = "t2.micro"
  key_name              = "server"
  vpc_security_group_ids = [aws_security_group.five.id]
  availability_zone     = "ap-south-1c"
  tags = {
    Name = "app-server-2"
  }
}

resource "aws_security_group" "five" {
  name = "elb-sg"
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

resource "aws_s3_bucket" "six" {
  bucket = "mohitdemoprojectofterraform-integration-1271"
}

resource "aws_iam_user" "seven" {
  for_each = var.user_names
  name     = each.value
}

variable "user_names" {
  description = "*"
  type        = set(string)
  default     = ["mohit1", "rohit1"]
}

resource "aws_ebs_volume" "eight" {
  availability_zone = "ap-south-1a"
  size              = 10
  tags = {
    Name = "terraform1-001"
  }
}

# Create default subnets if they do not exist
resource "aws_subnet" "default_a" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = "ap-south-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "default_b" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = "ap-south-1b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "default_c" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = "ap-south-1c"
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
}

data "aws_vpc" "default" {
  default = true
}
