variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC network"
  type        = string
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name   = string
    cidr   = string
    region = string
  }))
}

variable "enable_nat" {
  description = "Enable Cloud NAT for outbound internet access"
  type        = bool
  default     = true
}

variable "nat_region" {
  description = "Region where Cloud NAT will be deployed"
  type        = string
}
