variable "num_vms" {
  description = "Number of VMs to create"
  type        = number
  validation {
    condition     = var.num_vms >= 2 && var.num_vms <= 100
    error_message = "The number of VMs can vary between 2 and 100."
  }
}

variable "vm_flavor" {
  description = "Flavor of VM"
}

variable "cidr_block" {
  description = "The VPC CIDR range"
}

variable "public_key_path" {
  type    = string
  default = "/home/alinic/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  type    = string
  default = "/home/alinic/.ssh/id_rsa"
}