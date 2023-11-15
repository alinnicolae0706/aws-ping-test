terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
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

resource "null_resource" "ping_tests" {
  count = var.num_vms

  # Use the triggers block to create dependencies between null_resources
  triggers = {
    instance_ids = join(",", aws_instance.my_vm[*].id)
  }

  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      dest_instance_index=\$(((${count.index} + 1) % ${var.num_vms}))
      dest_instance_ip=\$(terraform output -json instance_private_ips | jq -r ".[${dest_instance_index}]")
      ping -c 1 \$dest_instance_ip
    EOT
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