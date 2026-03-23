output "vpc_id" {
  description = "Self-link of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnet_ids" {
  description = "Map of subnet name to self-link"
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.id }
}

output "subnet_regions" {
  description = "Map of subnet name to region"
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.region }
}
