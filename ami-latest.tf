# Ubuntu 16.04 latest AMI
data "aws_ami" "ubuntu16" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name  = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  owners = ["099720109477"]  # Canonical
}

# Ubuntu 14.04 latest AMI
data "aws_ami" "ubuntu14" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name  = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  owners = ["099720109477"]  # Canonical
}

# Windows 2016 Base latest AMI
data "aws_ami" "windows2016" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name  = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
  owners = ["801119661308"]  # Microsoft
}

# Windows 2012 R2 Base latest AMI
data "aws_ami" "windows2012" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name  = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
  owners = ["801119661308"]  # Microsoft
}

# Windows 2016 with Containers latest AMI
data "aws_ami" "windows2016-containers" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name  = "name"
    values = ["Windows_Server-2016-English-Full-Containers-*"]
  }
  owners = ["801119661308"]  # Microsoft
}