resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  name                     = each.value.name
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  private_ip_google_access = true # allows private VMs to reach Google APIs
}

resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.vpc_name}-router"
  region  = var.nat_region
  network = google_compute_network.vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  count  = var.enable_nat ? 1 : 0
  name   = "${var.vpc_name}-nat"
  router = google_compute_router.router[0].name
  region = var.nat_region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
