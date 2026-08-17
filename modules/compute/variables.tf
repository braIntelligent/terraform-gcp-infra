variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "instances" {
  description = "Map of instances to create"
  type = map(object({
    zone           = string
    subnet_id      = string
    machine_type   = string
    tags           = list(string)
    startup_script = optional(string, "")
  }))
}

variable "environment" {
  description = "Environment tag"
  type        = string
}
