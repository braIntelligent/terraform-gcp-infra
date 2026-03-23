terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Uncomment to use GCS backend for remote state
  # backend "gcs" {
  #   bucket = "your-tfstate-bucket"
  #   prefix = "terraform/dev"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  project_id = var.project_id
  vpc_name   = "${var.environment}-vpc"
  nat_region = var.region
  enable_nat = true

  subnets = [
    {
      name   = "${var.environment}-subnet-us"
      cidr   = "10.10.0.0/24"
      region = "us-central1"
    },
    {
      name   = "${var.environment}-subnet-sa"
      cidr   = "10.20.0.0/24"
      region = "southamerica-west1" 
    }
  ]
}

module "firewall" {
  source = "../../modules/firewall"

  project_id  = var.project_id
  vpc_name    = module.vpc.vpc_name
  environment = var.environment
}

module "compute" {
  source = "../../modules/compute"

  project_id  = var.project_id
  environment = var.environment

  instances = {
    "${var.environment}-app-01" = {
      zone         = "us-central1-a"
      subnet_id    = module.vpc.subnet_ids["${var.environment}-subnet-us"]
      machine_type = "e2-medium"
      tags         = ["allow-health-checks"]
    }
    "${var.environment}-app-sa-01" = {
      zone         = "southamerica-west1-a"
      subnet_id    = module.vpc.subnet_ids["${var.environment}-subnet-sa"]
      machine_type = "e2-small"
      tags         = []
    }
  }
}
