output "instance_names" {
  description = "Names of created instances"
  value       = { for k, v in google_compute_instance.instances : k => v.name }
}

output "instance_internal_ips" {
  description = "Internal IPs of created instances"
  value       = { for k, v in google_compute_instance.instances : k => v.network_interface[0].network_ip }
}
