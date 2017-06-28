# Specify the provider and access details
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "Demo-VPC" {
  cidr_block           = "10.10.0.0/24"
  enable_dns_hostnames = true

  tags {
    Name = "Demo-VPC"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "igw-demo" {
  vpc_id = "${aws_vpc.Demo-VPC.id}"

  tags {
    Name = "IGW-Demo"
  }
}

# Create a public subnet to launch our instances into 
# 10.10.0.0 - 10.10.0.127
resource "aws_subnet" "subnet-public-demo" {
  vpc_id                  = "${aws_vpc.Demo-VPC.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "10.10.0.0/25"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.igw-demo"]

  tags {
    Name = "subnet-public-demo"
  }
}

# Create private subnets to launch our instances into 
# 10.10.0.128 - 10.50.0.255
resource "aws_subnet" "subnet-private-demo" {
  vpc_id            = "${aws_vpc.Demo-VPC.id}"
  availability_zone = "us-east-1a"
  cidr_block        = "10.50.0.128/25"
  depends_on        = ["aws_internet_gateway.igw-demo"]

  tags {
    Name = "subnet-private-demo"
  }
}

# Route Table for Public subnet and Peering association
resource "aws_route_table" "rtb-public-subnet" {
  vpc_id = "${aws_vpc.Demo-VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-demo.id}"
  }

  route {
    cidr_block                = "172.31.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.Demo-to-Build.id}"
  }

  tags {
    Name = "Demo-Public-RTB"
  }
}

# A security group for the web server instances
resource "aws_security_group" "demo-web-sg" {
  name        = "demo-web-sg"
  description = "Security Group for Demo web Nodes"
  vpc_id      = "${aws_vpc.Demo-VPC.id}"

  tags {
    Name = "demo-SG"
  }

  # Inbound HTTP
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
        "0.0.0.0/0"
    ]  
  }

  # Inbound HTTPS
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
        "0.0.0.0/0"
    ]  
  }

  # Inbound SSH
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
        "${var.vpn_ip}",      # OpenVPN
        "${var.office_ip}",    # Local office IP 
    ]  
  }

  # RDP access
  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
    cidr_blocks = [
        "${var.vpn_ip}",   # OpenVPN
        "${var.office_ip}", # Local office IP
    ] 
  }

  # Allow to ping
  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"
    cidr_blocks = [
        "172.31.0.0/16",     # Build VPC
        "10.20.0.0/24",      # Selenium VPC
        "10.10.10.0/24",     # MDC VPC
        "${var.vpn_ip}",   # OpenVPN
        "${var.office_ip}", # Local office IP
    ]
  }

  # SQL Server
  ingress {
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"
    cidr_blocks = [
        "172.31.0.0/16",   # Build VPC
        "${var.vpn_ip}", # OpenVPN 
    ]
  }

  # Outbound HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound ping
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SQL Server
  egress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [
        "172.31.0.0/16",   # Build VPC
        "10.10.0.0/24",    # Selenium VPC
        "${var.vpn_ip}", # OpenVPN 
    ]
  }
}

 resource "aws_instance" "ubuntu-web" {
    ami                    = "${data.aws_ami.ubuntu16.id}"
    instance_type          = "t2.micro"
    key_name               = "${var.aws_key_name}"
    availability_zone      = "us-east-1a"
    subnet_id              = "${aws_subnet.subnet-public-demo.id}"
    vpc_security_group_ids = ["${aws_security_group.yolo-sg.id}"]
    key_name               = "playground"
    user_data              = "${file("userdata.bash")}"
 
   tags {
     Name  = "web-server"
     App   = "demo"
     Env   = "web"
     Owner = "bryan"
     OS    = "ubuntu16"
   }
}