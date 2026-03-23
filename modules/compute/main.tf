resource "google_compute_instance" "instances" {
  for_each = var.instances

  name         = each.key
  machine_type = each.value.machine_type
  zone         = each.value.zone
  project      = var.project_id

  tags = concat(each.value.tags, ["iap-ssh"])

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = each.value.subnet_id
    # No access_config block = no public IP (private only, access via IAP)
  }

  metadata = {
    startup-script = each.value.startup_script
    # Disable legacy metadata endpoints for security
    disable-legacy-endpoints = "true"
  }

  # Use default compute service account with minimal scopes
  service_account {
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}
