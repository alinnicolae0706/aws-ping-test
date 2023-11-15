output "ping_results" {
  value = null_resource.ping_test[*].exit_code
}