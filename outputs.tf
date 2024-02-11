output "test_vms_private_ips" {
  value = aws_instance.test_vm[*].private_ip
}

output "test_vms_public_ips" {
  value = aws_instance.test_vm[*].public_ip
}