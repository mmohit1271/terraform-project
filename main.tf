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

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-b"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-c"
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

# Route Table Associations
resource "aws_route_table_association" "subnet_a_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_b_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet_c_association" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.route_table.id
}

# Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id
  name   = "terraform-sg"

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

  tags = {
    Name = "terraform-sg"
  }
}

# EC2 Instances
resource "aws_instance" "web_server_1" {
  ami           = "ami-0fd05997b4dff7aac"
  instance_type = "t2.micro"
  key_name      = "server"
  subnet_id     = aws_subnet.subnet_a.id
  availability_zone = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<EOF
#!/bin/bash
sudo yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "Welcome to Web Server 1" > /var/www/html/index.html
EOF

  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "web_server_2" {
  ami           = "ami-0fd05997b4dff7aac"
  instance_type = "t2.micro"
  key_name      = "server"
  subnet_id     = aws_subnet.subnet_c.id
  availability_zone = "ap-south-1c"
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<EOF
#!/bin/bash
sudo yum install httpd -y
systemctl start httpd
chkconfig httpd on
echo "Welcome to Web Server 2" > /var/www/html/index.html
EOF

  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "app_server_1" {
  ami           = "ami-0fd05997b4dff7aac"
  instance_type = "t2.micro"
  key_name      = "server"
  subnet_id     = aws_subnet.subnet_b.id
  availability_zone = "ap-south-1b"
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "app-server-1"
  }
}

resource "aws_instance" "app_server_2" {
  ami           = "ami-0fd05997b4dff7aac"
  instance_type = "t2.micro"
  key_name      = "server"
  subnet_id     = aws_subnet.subnet_c.id
  availability_zone = "ap-south-1c"
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "app-server-2"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "mohitdemoprojectofterraform-integration-1271"
  acl    = "private"
  tags = {
    Name = "terraform-s3-bucket"
  }
}

# IAM Users
resource "aws_iam_user" "iam_users" {
  for_each = var.user_names
  name     = each.value
  tags = {
    Name = "terraform-iam-user"
  }
}

variable "user_names" {
  type    = set(string)
  default = ["mohit1", "rohit1"]
}

# EBS Volumes
resource "aws_ebs_volume" "ebs_a" {
  availability_zone = "ap-south-1a"
  size              = 8
  tags = {
    Name = "terraform-ebs-a"
  }
}

