terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "vm_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04*"]
  }
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.num_vms
}

resource "aws_vpc" "vm_vpc" {
  cidr_block = local.vpc_cidr
  tags = {
    Name = "vm-vpc"
  }
}

resource "aws_subnet" "vm_subnet" {
  count                   = var.num_vms
  cidr_block              = [for i in range(1, 255, 1) : cidrsubnet(local.vpc_cidr, 8, i)][count.index]
  vpc_id                  = aws_vpc.vm_vpc.id
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "vm-subnet-${count.index}"
  }
}

resource "aws_instance" "test_vm" {
  count         = var.num_vms
  ami           = data.aws_ami.vm_ami.image_id
  instance_type = var.vm_flavor
  subnet_id     = aws_subnet.vm_subnet[count.index].id
  key_name      = aws_key_pair.ssh_auth.id
  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.icmp.id
  ]
  # provisioner "remote-exec" {
  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     host        = self.public_ip
  #     private_key = file(var.private_key_path)
  #   }
  #   inline = ["echo 'Hello, World!' > /home/ubuntu/write_test.txt"]
  # }
  tags = {
    Name = "test-vm-${count.index}"
  }
}

resource "aws_key_pair" "ssh_auth" {
  key_name   = "ssh-key-pair"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "icmp" {
  name        = "ping-access"
  description = "Allow ICMP access"
  vpc_id      = aws_vpc.vm_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh-access"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.vm_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "null_resource" "ping_round_robin" {
  count = var.num_vms

  triggers = {
    vm_index = count.index
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.test_vm[count.index].public_ip
      private_key = file(var.private_key_path)
    }
    inline = [
      "source_vm=${count.index}",
      "target_vm=$((($source_vm + 1) % ${var.num_vms}))",
      "ip_addr=$(terraform output -json test_vms_private_ips | jq -r \".[$target_vm]\")",
      "ping -c 4 $ip_addr"
    ]
  }
}