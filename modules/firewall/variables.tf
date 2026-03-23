variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name to attach rules"
  type        = string
}

variable "environment" {
  description = "Environment tag (dev, staging, prod)"
  type        = string
}
