variable "num_vms" {
  description = "Number of VMs to create"
}

variable "vm_flavor" {
  description = "Flavor of VM"
}

variable "vm_image" {
  description = "AMI ID for VM"
}

variable "cidr_block" {
  description = "The IP range for the VPC"
}

variable "subnet" {
  description = "The subnet range for the VPC"
}