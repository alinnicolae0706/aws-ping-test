# README
# Terraform AWS VM Deployment

## Variables

- **num_vms**: Number of VMs to create (between 2 and 100).
- **vm_flavor**: Flavor of VM (e.g., "t2.micro").
- **vpc_cidr**: The VPC CIDR where the VMs will be deployed.

## How to Use

1. Set your AWS credentials using environment variables or AWS CLI configuration.
2. Modify the `terraform.tfvars` file with your desired values.
  - set the desired number of VMs.
  - choose the VM flavor.
3. Set the VPC CIDR value in the `locals.tf` file.
4. Run the following Terraform commands:

```bash
terraform init
terraform fmt --recursive
terraform validate
terraform plan
terraform apply
# To eliminate interactive mode:
terraform apply --auto-aprove