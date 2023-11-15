provider "aws" {
  version = "~> 3.0"
  region  = "eu-central-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  count = var.num_vms
  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "vm-subnet-${count.index}"
  }
}

resource "aws_instance" "my_vm" {
  count = var.num_vms
  ami           = var.vm_image
  instance_type = var.vm_flavor
  subnet_id     = aws_subnet.my_subnet[count.index].id
  tags = {
    Name = "vm-${count.index}"
  }
}

resource "null_resource" "ping_test" {
  count = var.num_vms
  provisioner "local-exec" {
    command = "ping -c 1 ${element(aws_instance.my_vm.*.private_ip, count.index)}"
  }
}

resource "aws_security_group" "allow_pings" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}