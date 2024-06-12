provider "aws" {
  region = "us-east-2"
}


resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.subnet1_cidr_block
  availability_zone = var.avail_zone1
  map_public_ip_on_launch = true

  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.subnet2_cidr_block
  availability_zone = var.avail_zone2
  map_public_ip_on_launch = true

  tags = {
    Name: "${var.env_prefix}-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    to_port = 22
    from_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    to_port = 80
    from_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023.4.20240611.0-kernel-*-x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server1" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  tags = {
    Name: "${var.env_prefix}-server1"
  }
}

output "ec2_public_ip_server1" {
  value = aws_instance.myapp-server1.public_ip
}

resource "aws_instance" "myapp-server2" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script1.sh")

  tags = {
    Name: "${var.env_prefix}-server2"
  }
}

output "ec2_public_ip_server2" {
  value = aws_instance.myapp-server2.public_ip
}