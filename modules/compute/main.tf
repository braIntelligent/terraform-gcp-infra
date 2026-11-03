# Identidad propia de las VM, en vez de la cuenta por defecto de Compute Engine,
# que suele traer el rol Editor sobre el proyecto.
resource "google_service_account" "vm" {
  account_id   = "${var.environment}-vm"
  display_name = "VMs ${var.environment}"
  project      = var.project_id
}

resource "google_project_iam_member" "vm" {
  for_each = toset(["roles/logging.logWriter", "roles/monitoring.metricWriter"])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm.email}"
}

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

  # Excepción aceptada: laboratorio sin datos sensibles; una clave KMS agrega
  # costo y operación que acá no se justifican. Producción sí la usaría.
  #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
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
    # Solo claves de esta instancia: una clave del proyecto no abre todas las VM
    block-project-ssh-keys = true
  }

  # El scope es amplio a propósito (recomendación de Google): lo que la VM puede
  # hacer lo limitan los roles IAM de la cuenta, no el scope.
  service_account {
    email  = google_service_account.vm.email
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
