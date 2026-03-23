output "vpc_name" {
  description = "VPC network name"
  value       = module.vpc.vpc_name
}

output "subnet_ids" {
  description = "Created subnet IDs"
  value       = module.vpc.subnet_ids
}

output "instance_ips" {
  description = "Internal IPs of all instances"
  value       = module.compute.instance_internal_ips
}
