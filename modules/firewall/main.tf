# Allow SSH only via IAP (Identity-Aware Proxy) — no direct SSH from internet
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.vpc_name}-allow-iap-ssh"
  network = var.vpc_name
  project = var.project_id

  description = "Allow SSH from Google IAP only — no direct internet SSH"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Google IAP source range — official documented range
  source_ranges = ["35.235.240.0/20"]

  target_tags = ["iap-ssh"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow internal traffic within VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.vpc_name}-allow-internal"
  network = var.vpc_name
  project = var.project_id

  description = "Allow all internal traffic within VPC subnets"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

# Allow health checks from Google load balancers
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.vpc_name}-allow-health-checks"
  network = var.vpc_name
  project = var.project_id

  description = "Allow Google Cloud health check probes for load balancers"

  allow {
    protocol = "tcp"
  }

  # Official Google health check source ranges
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["allow-health-checks"]
}

# Deny all ingress by default (explicit — GCP already does this implicitly)
# This makes the intent visible in code
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "${var.vpc_name}-deny-all-ingress"
  network   = var.vpc_name
  project   = var.project_id
  priority  = 65534
  direction = "INGRESS"

  description = "Explicit deny-all ingress at lowest priority — defense in depth"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
