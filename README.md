# README
# Terraform AWS VM Deployment

## Variables

- **num_vms**: Number of VMs to create (between 2 and 100).
- **vm_flavor**: Flavor of VM (e.g., "t2.micro").
- **vm_image**: AMI ID for VM.

## How to Use

1. Set your AWS credentials using environment variables or AWS CLI configuration.
2. Modify the `example.tfvars` file with your desired values.
3. Run the following Terraform commands:

```bash
terraform init
terraform apply -var-file=example.tfvars